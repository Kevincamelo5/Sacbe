extends Node2D

# --- PALETA MAYA ---
const PALETA_PIEDRA_FONDO := Color("#E8D9BD")
const PALETA_GLIFO_TEXTO := Color("#765D46")
const PALETA_ACENTO_TURQUESA := Color("#009FA1")
const PALETA_BORDE_NEGRO := Color("#000000")

# --- VARIABLES DEL MINIJUEGO ---
var vidas: int = 5
var puertas_superadas: int = 0
var respuesta_correcta: String = ""

# --- REFERENCIAS ---
@onready var label_problema: Label = $LabelProblema # O la ruta donde esté tu Label
@onready var puerta_1 = $Puertas/Puerta1
@onready var puerta_2 = $Puertas/Puerta2
@onready var puerta_3 = $Puertas/Puerta3
@onready var jugador = $Jugador 

func _ready() -> void:
	_estilizar_label_problema()
	
	puerta_1.puerta_golpeada.connect(_on_puerta_atacada)
	puerta_2.puerta_golpeada.connect(_on_puerta_atacada)
	puerta_3.puerta_golpeada.connect(_on_puerta_atacada)
	
	generar_problema_division()

func _estilizar_label_problema() -> void:
	if not label_problema:
		return
		
	var style_panel = StyleBoxFlat.new()
	style_panel.bg_color = PALETA_PIEDRA_FONDO.darkened(0.05)
	style_panel.border_color = PALETA_ACENTO_TURQUESA
	style_panel.border_width_left = 5
	style_panel.border_width_right = 5
	style_panel.border_width_top = 5
	style_panel.border_width_bottom = 5
	style_panel.corner_radius_top_left = 15
	style_panel.corner_radius_top_right = 15
	style_panel.corner_radius_bottom_left = 15
	style_panel.corner_radius_bottom_right = 15
	style_panel.content_margin_left = 30
	style_panel.content_margin_right = 30
	style_panel.content_margin_top = 15
	style_panel.content_margin_bottom = 15
	style_panel.shadow_color = Color(0, 0, 0, 0.4)
	style_panel.shadow_size = 6
	style_panel.shadow_offset = Vector2(3, 3)

	label_problema.add_theme_stylebox_override("normal", style_panel)
	label_problema.add_theme_color_override("font_color", PALETA_GLIFO_TEXTO)
	label_problema.add_theme_font_size_override("font_size", 48)
	label_problema.add_theme_constant_override("outline_size", 2)
	label_problema.add_theme_color_override("font_outline_color", PALETA_BORDE_NEGRO)
	label_problema.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func generar_problema_division() -> void:
	randomize()
	var tipo_operacion = randi() % 2 
	var opciones = []

	if tipo_operacion == 0:
		# Fracciones
		var num1 = randi_range(1, 5)
		var den1 = randi_range(2, 5)
		var entero = randi_range(2, 5)
		label_problema.text = str(num1) + "/" + str(den1) + " ÷ " + str(entero)
		var res_num = num1
		var res_den = den1 * entero
		respuesta_correcta = str(res_num) + "/" + str(res_den)
		opciones.append(respuesta_correcta)
		opciones.append(str(res_num) + "/" + str(res_den + randi_range(1, 3)))
		opciones.append(str(res_num) + "/" + str(res_den - 1))
	else:
		# Decimales
		var divisor = randi_range(2, 6)
		var res_exacto = randi_range(11, 40) / 10.0
		var dividendo = snapped(res_exacto * divisor, 0.1)
		label_problema.text = str(dividendo) + " ÷ " + str(divisor)
		respuesta_correcta = str(res_exacto)
		opciones.append(respuesta_correcta)
		opciones.append(str(snapped(res_exacto + 1.1, 0.1)))
		opciones.append(str(snapped(res_exacto - 0.3, 0.1)))

	opciones.shuffle()

	_restaurar_puertas()
	puerta_1.configurar_puerta(opciones[0])
	puerta_2.configurar_puerta(opciones[1])
	puerta_3.configurar_puerta(opciones[2])

func _on_puerta_atacada(texto_elegido: String, puerta_atacada: Node2D) -> void:
	if texto_elegido == respuesta_correcta:
		puerta_atacada.romper_puerta()
		puertas_superadas += 1
		
		for p in [puerta_1, puerta_2, puerta_3]:
			if p != puerta_atacada:
				p.visible = false
				p.esta_activa = false
				
		await get_tree().create_timer(1.0).timeout
		
		if puertas_superadas >= 5:
			print("¡NIVEL SUPERADO!")
		else:
			generar_problema_division()
			
	else:
		puerta_atacada.castigar_jugador()
		vidas -= 1
		print("Vidas restantes: ", vidas)
		
		if jugador.has_method("recibir_dano"):
			jugador.recibir_dano(1)
		elif jugador.has_method("_lose_lives"):
			jugador._lose_lives()

func _restaurar_puertas() -> void:
	for p in [puerta_1, puerta_2, puerta_3]:
		p.scale = Vector2(1, 1)
		p.modulate.a = 1.0
		p.visible = true
