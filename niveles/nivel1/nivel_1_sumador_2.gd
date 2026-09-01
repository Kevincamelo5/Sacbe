extends Control

# --- PALETA DE COLORES INSPIRADA EN LA IMAGEN DE FONDO MAYA ---
const PALETA_PIEDRA_FONDO := Color("#E8D9BD") # Crema envejecido
const PALETA_GLIFO_TEXTO := Color("#765D46")  # Marrón glifo descolorido
const PALETA_ACENTO_TURQUESA := Color("#009FA1") # Turquesa brillante
const PALETA_ACENTO_AZUL := Color("#006494")     # Azul más oscuro
const PALETA_ACENTO_ROJO := Color("#B53F1A")     # Rojo anaranjado quemado
const PALETA_BORDE_NEGRO := Color("#000000")    # Contornos de glifos

const TEX_FONDO_MAYOR := preload("res://activos/arte/cueva.jpg") 

# Referencias a tus nodos (Ajusta las rutas según tu árbol de nodos)
@onready var label_problema: Label = $VBoxContainer/LabelProblema
@onready var boton_1: Button = $VBoxContainer/HBoxContainer/Boton1
@onready var boton_2: Button = $VBoxContainer/HBoxContainer/Boton2
@onready var boton_3: Button = $VBoxContainer/HBoxContainer/Boton3

# Referencia al TextureRect de fondo (se crea por código si no existe)
var _texture_fondo_mayor: TextureRect

var respuesta_correcta: String = ""
var correctos: int = 0

func _ready() -> void:
	# --- CONFIGURACIÓN DEL FONDO MAYA ---
	_texture_fondo_mayor = TextureRect.new()
	_texture_fondo_mayor.name = "TextureRectFondoMayor"
	add_child(_texture_fondo_mayor)
	move_child(_texture_fondo_mayor, 0) # Asegurar que esté detrás de todo

	_texture_fondo_mayor.texture = TEX_FONDO_MAYOR
	_texture_fondo_mayor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_texture_fondo_mayor.stretch_mode = TextureRect.STRETCH_SCALE
	_texture_fondo_mayor.set_anchors_preset(Control.PRESET_FULL_RECT)

	# --- ESTILO DEL PANEL DEL PROBLEMA ---
	var style_panel_problema = StyleBoxFlat.new()
	style_panel_problema.bg_color = PALETA_PIEDRA_FONDO.darkened(0.05)
	style_panel_problema.border_color = PALETA_ACENTO_TURQUESA
	style_panel_problema.border_width_left = 6
	style_panel_problema.border_width_right = 6
	style_panel_problema.border_width_top = 6
	style_panel_problema.border_width_bottom = 6
	style_panel_problema.corner_radius_top_left = 15
	style_panel_problema.corner_radius_top_right = 15
	style_panel_problema.corner_radius_bottom_left = 15
	style_panel_problema.corner_radius_bottom_right = 15
	style_panel_problema.content_margin_left = 40
	style_panel_problema.content_margin_right = 40
	style_panel_problema.content_margin_top = 30
	style_panel_problema.content_margin_bottom = 30
	style_panel_problema.shadow_color = Color(0, 0, 0, 0.4)
	style_panel_problema.shadow_size = 5
	style_panel_problema.shadow_offset = Vector2(3, 3)

	label_problema.add_theme_stylebox_override("normal", style_panel_problema)
	label_problema.add_theme_color_override("font_color", PALETA_GLIFO_TEXTO)
	label_problema.add_theme_font_size_override("font_size", 64)
	label_problema.add_theme_constant_override("outline_size", 2)
	label_problema.add_theme_color_override("font_outline_color", PALETA_BORDE_NEGRO)
	label_problema.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# --- ESTILO DE LOS BOTONES DE OPCIONES ---
	var style_btn_normal = _crear_estilo_boton_piedra_maya(PALETA_PIEDRA_FONDO)
	var style_btn_hover = _crear_estilo_boton_piedra_maya(PALETA_PIEDRA_FONDO, true)
	var style_btn_pressed = _crear_estilo_boton_piedra_maya(PALETA_ACENTO_TURQUESA)

	# Aplicar el estilo a los 3 botones usando un arreglo
	var botones = [boton_1, boton_2, boton_3]
	for btn in botones:
		btn.add_theme_stylebox_override("normal", style_btn_normal)
		btn.add_theme_stylebox_override("hover", style_btn_hover)
		btn.add_theme_stylebox_override("pressed", style_btn_pressed)
		
		btn.add_theme_color_override("font_color", PALETA_GLIFO_TEXTO)
		btn.add_theme_color_override("font_hover_color", PALETA_ACENTO_TURQUESA)
		btn.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
		
		btn.add_theme_font_size_override("font_size", 48)
		btn.add_theme_constant_override("outline_size", 2)
		btn.add_theme_color_override("font_outline_color", PALETA_BORDE_NEGRO)
		
		# Expansión para que llenen el HBoxContainer de manera equitativa
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Conectamos los botones a una misma función
	boton_1.pressed.connect(_on_boton_presionado.bind(boton_1))
	boton_2.pressed.connect(_on_boton_presionado.bind(boton_2))
	boton_3.pressed.connect(_on_boton_presionado.bind(boton_3))
	
	# Ajustamos separación en el contenedor padre si es posible para centrar todo un poco
	$VBoxContainer.add_theme_constant_override("separation", 50)
	
	generar_problema()
	$AnimatedSprite2D.play("static")

# Función helper para crear un StyleBoxFlat con aspecto tallado
func _crear_estilo_boton_piedra_maya(accent_color: Color = PALETA_PIEDRA_FONDO, is_hover: bool = false) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = accent_color
	style.border_color = PALETA_BORDE_NEGRO
	style.border_width_left = 4
	style.border_width_right = 4
	style.border_width_top = 4
	style.border_width_bottom = 4
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	style.draw_center = true
	
	if accent_color == PALETA_PIEDRA_FONDO:
		style.set_bg_color(PALETA_PIEDRA_FONDO.lightened(0.05))
		style.bg_color = PALETA_PIEDRA_FONDO
	else:
		style.set_bg_color(accent_color.lightened(0.2) if is_hover else accent_color.lightened(0.1))
		style.bg_color = accent_color
	
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 5
	style.shadow_offset = Vector2(3, 3)
	
	# MÁRGENES INTERNOS PARA QUE LOS BOTONES SEAN GRANDES
	style.content_margin_left = 30
	style.content_margin_right = 30
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	
	return style

func generar_problema() -> void:
	randomize()
	var tipo_operacion = randi() % 2 
	var opciones = []

	if tipo_operacion == 0:
		# --- LÓGICA DE FRACCIONES SIMPLIFICADA (Suma con mismo denominador) ---
		var denominador = randi_range(2, 6)
		var num1 = randi_range(1, 5)
		var num2 = randi_range(1, 5)

		label_problema.text = str(num1) + "/" + str(denominador) + " + " + str(num2) + "/" + str(denominador)

		var res_num = num1 + num2
		respuesta_correcta = str(res_num) + "/" + str(denominador)
		opciones.append(respuesta_correcta)

		# Opciones falsas (sumando al numerador final)
		opciones.append(str(res_num + randi_range(1, 2)) + "/" + str(denominador))
		opciones.append(str(res_num + randi_range(3, 4)) + "/" + str(denominador))

	else:
		# --- LÓGICA DE DECIMALES SIMPLIFICADA (Decimal + Decimal) ---
		var val1 = randi_range(11, 50) / 10.0 # 1.1 a 5.0
		var val2 = randi_range(11, 50) / 10.0 # 1.1 a 5.0

		label_problema.text = str(val1) + " + " + str(val2)

		var res_exacto = snapped(val1 + val2, 0.1)
		respuesta_correcta = str(res_exacto)
		opciones.append(respuesta_correcta)

		# Opciones falsas
		opciones.append(str(snapped(res_exacto + 1.0, 0.1)))
		opciones.append(str(snapped(res_exacto - 0.4, 0.1)))

	opciones.shuffle()

	boton_1.text = opciones[0]
	boton_2.text = opciones[1]
	boton_3.text = opciones[2]

func _on_boton_presionado(boton: Button) -> void:
	if boton.text == respuesta_correcta:
		print("¡Respuesta Correcta!")
		_es_respuesta_correcta()
	else:
		print("Respuesta Incorrecta")
		_es_respuesta_incorrecta()

# ==========================================================
# ANIMACIONES Y LÓGICA DE PROGRESIÓN (Estilizadas)
# ==========================================================

func _es_respuesta_correcta() -> void:
	# Crear canvas layer para el efecto
	var canvas := CanvasLayer.new()
	canvas.layer = 100  # Alta prioridad para que esté por encima de todo
	get_tree().root.add_child(canvas)
	
	$AnimatedSprite2D.play("acerted")
	# Crear fondo semitransparente verde
	var color_rect := ColorRect.new()
	color_rect.color = Color(0.2, 0.8, 0.3, 0.0)  # Verde más suave
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(color_rect)
	
	# Crear centrador del texto
	var contenedor := CenterContainer.new()
	contenedor.set_anchors_preset(PRESET_FULL_RECT)
	canvas.add_child(contenedor)
	
	# Crear mensaje de éxito
	var label := Label.new()
	label.text = "¡CORRECTO!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_color_override("font_outline_color", Color(0, 0.3, 0))
	label.modulate = Color(1, 1, 1, 0)  # Inicialmente transparente
	contenedor.add_child(label)
	
	# Crear tween para animaciones
	var tween := get_tree().create_tween()
	tween.set_parallel(true)  # Animaciones en paralelo
	
	# Animación del fondo
	tween.tween_property(color_rect, "color:a", 0.3, 0.3)
	tween.tween_property(color_rect, "color:a", 0.0, 0.82).set_delay(0.5)
	
	# Animación del texto
	tween.tween_property(label, "modulate:a", 1.0, 0.3)
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.3).set_delay(0.2)
	tween.tween_property(label, "modulate:a", 0.0, 0.3).set_delay(0.7)
	
	await tween.finished
	
	# Limpiar y generar nuevo problema
	_aumentar_aciertos()
	canvas.queue_free()
	generar_problema()

func _aumentar_aciertos() -> int:
	correctos += 1
	print("Correctos: ", correctos)
	if correctos >= 5:
		get_tree().change_scene_to_file("res://niveles/nivel3/nivel3_parte2_cutscene.tscn")
	return correctos

func _es_respuesta_incorrecta() -> void:
	# Crear canvas layer para el efecto
	var canvas := CanvasLayer.new()
	canvas.layer = 100  # Alta prioridad para que esté por encima de todo
	get_tree().root.add_child(canvas)
	
	# Crear fondo semitransparente rojo/rosa
	var color_rect := ColorRect.new()
	color_rect.color = Color(0.588, 0.11, 0.344, 0.0) 
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(color_rect)
	
	# Crear centrador del texto
	var contenedor := CenterContainer.new()
	contenedor.set_anchors_preset(PRESET_FULL_RECT)
	canvas.add_child(contenedor)
	
	# Crear mensaje de error
	var label := Label.new()
	label.text = "¡INCORRECTO!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_color_override("font_outline_color", Color(0.433, 0.109, 0.105, 1.0))
	label.modulate = Color(1, 1, 1, 0)  # Inicialmente transparente
	contenedor.add_child(label)
	
	# Crear tween para animaciones
	var tween := get_tree().create_tween()
	tween.set_parallel(true)  # Animaciones en paralelo
	
	# Animación del fondo
	tween.tween_property(color_rect, "color:a", 0.3, 0.3)
	tween.tween_property(color_rect, "color:a", 0.0, 0.82).set_delay(0.5)
	
	# Animación del texto
	tween.tween_property(label, "modulate:a", 1.0, 0.3)
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.3).set_delay(0.2)
	tween.tween_property(label, "modulate:a", 0.0, 0.3).set_delay(0.7)
	
	await tween.finished
	
	# Limpiar y generar nuevo problema
	canvas.queue_free()
	generar_problema()
