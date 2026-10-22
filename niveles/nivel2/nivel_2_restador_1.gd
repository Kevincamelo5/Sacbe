extends Control

signal comprobar_respuesta(String)
signal colocar_caracter(String)
signal eliminar_caracter

const PALETA_PIEDRA_FONDO := Color("#E8D9BD") # Crema envejecido
const PALETA_GLIFO_TEXTO := Color("#765D46")  # Marrón glifo descolorido
const PALETA_ACENTO_TURQUESA := Color("#009FA1") # Turquesa brillante
const PALETA_ACENTO_AZUL := Color("#006494")     # Azul más oscuro
const PALETA_ACENTO_ROJO := Color("#B53F1A")     # Rojo anaranjado quemado
const PALETA_BORDE_NEGRO := Color("#000000")    # Contornos de glifos
const COLOR_FONDO := Color(0.392, 0.435, 0.465, 1.0)
const COLOR_FONDO_BOTONES := Color(0.036, 0.0, 0.339, 0.914)
const TEX_FONDO_PROBLEMA := preload("res://activos/arte/Gemini_Generated_Image_80ljf80ljf80ljf8.png") 
const OPERADOR := "-"

# --- PRECIOS DE LAS ARMAS ---
const PRECIOS := {
	"flauta": 15,
	"hacha": 35,
	"lanza": 40
}

@onready var _contenedor_botones: GridContainer = $fondos2/derecha/CenterContainer/GridContainer
@onready var _campo_respuesta: LineEdit = $fondos2/izquierda/CenterContainer/VBoxContainer/LineEdit
@onready var _campo_operandos: Label = $fondos2/izquierda/CenterContainer/VBoxContainer/Label
@onready var _boton_enviar: Button = $fondos2/izquierda/MarginContainer/CenterContainer/BotonEnviar
@onready var contenedor_objetos = $ContenedorObjetos
@onready var boton_flauta = $ContenedorObjetos/BotonFlauta
@onready var boton_hacha = $ContenedorObjetos/BotonHacha
@onready var boton_lanza = $ContenedorObjetos/BotonLanza

@onready var _texture_fondo_mayor: TextureRect = $TextureRect

var _operador:= '-'
var _operandos:= []
var _respuesta_correcta := "0"

var label_aciertos: Label
var label_error_dinero: Label

var respuesta_correcta: String = ""
var correctos: int = 0
const ACIERTOS_OBJETIVO: int = 5

func _ready() -> void:
	if contenedor_objetos:
		contenedor_objetos.hide()
		boton_flauta.pressed.connect(_seleccionar_objeto.bind("flauta"))
		boton_hacha.pressed.connect(_seleccionar_objeto.bind("hacha"))
		boton_lanza.pressed.connect(_seleccionar_objeto.bind("lanza"))
	 
	if not _texture_fondo_mayor:
		_texture_fondo_mayor = TextureRect.new()
		_texture_fondo_mayor.name = "TextureRectFondoMayor"
		add_child(_texture_fondo_mayor)
		move_child(_texture_fondo_mayor, 0)

	_texture_fondo_mayor.texture = TEX_FONDO_PROBLEMA
	_texture_fondo_mayor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_texture_fondo_mayor.stretch_mode = TextureRect.STRETCH_SCALE
	_texture_fondo_mayor.set_anchors_preset(Control.PRESET_FULL_RECT)

	_crear_contador_aciertos()
	_crear_label_error()
	
	var margins_centrales := 100
	$fondos2.set_anchors_preset(Control.PRESET_FULL_RECT)
	$fondos2.add_theme_constant_override("margin_left", margins_centrales)
	$fondos2.add_theme_constant_override("margin_right", margins_centrales)
	$fondos2.add_theme_constant_override("margin_top", margins_centrales + 50)
	$fondos2.add_theme_constant_override("margin_bottom", margins_centrales)

	_crear_botones()
	
	self.colocar_caracter.connect(_on_colocar_caracter)
	self.eliminar_caracter.connect(_on_eliminar_caracter)
	self.comprobar_respuesta.connect(_on_comprobar_respuesta)
	
	var style_enviar_normal = _crear_estilo_boton_piedra_maya(PALETA_ACENTO_TURQUESA)
	var style_enviar_hover = _crear_estilo_boton_piedra_maya(PALETA_ACENTO_TURQUESA, true)
	var style_enviar_pressed = _crear_estilo_boton_piedra_maya(PALETA_ACENTO_AZUL)
	for estilo in [style_enviar_normal, style_enviar_hover, style_enviar_pressed]:
		estilo.content_margin_left = 20
		estilo.content_margin_right = 20
		estilo.content_margin_top = 15
		estilo.content_margin_bottom = 15
	_boton_enviar.add_theme_stylebox_override("normal", style_enviar_normal)
	_boton_enviar.add_theme_stylebox_override("hover", style_enviar_hover)
	_boton_enviar.add_theme_stylebox_override("pressed", style_enviar_pressed)
	_boton_enviar.add_theme_color_override("font_color", PALETA_PIEDRA_FONDO)
	_boton_enviar.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	_boton_enviar.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
	_boton_enviar.add_theme_font_size_override("font_size", 45)
	_boton_enviar.add_theme_constant_override("outline_size", 2)
	_boton_enviar.add_theme_color_override("font_outline_color", PALETA_BORDE_NEGRO)
	_boton_enviar.pressed.connect(func(): comprobar_respuesta.emit(_campo_respuesta.get_text()))
	
	var style_campo = StyleBoxFlat.new()
	style_campo.bg_color = PALETA_PIEDRA_FONDO.darkened(0.1)
	style_campo.border_color = PALETA_GLIFO_TEXTO
	style_campo.border_width_left = 4
	style_campo.border_width_right = 4
	style_campo.border_width_top = 4
	style_campo.border_width_bottom = 4
	style_campo.corner_radius_top_left = 10
	style_campo.corner_radius_top_right = 10
	style_campo.corner_radius_bottom_left = 10
	style_campo.corner_radius_bottom_right = 10
	
	_campo_respuesta.add_theme_stylebox_override("normal", style_campo)
	_campo_respuesta.add_theme_stylebox_override("focus", style_campo)
	_campo_respuesta.add_theme_color_override("font_color", PALETA_GLIFO_TEXTO)
	_campo_respuesta.add_theme_color_override("caret_color", PALETA_ACENTO_TURQUESA)
	_campo_respuesta.add_theme_font_size_override("font_size", 45)
	_campo_respuesta.add_theme_constant_override("outline_size", 2)
	_campo_respuesta.add_theme_color_override("font_outline_color", PALETA_BORDE_NEGRO)

	var style_panel_problema = StyleBoxFlat.new()
	style_panel_problema.bg_color = PALETA_PIEDRA_FONDO.darkened(0.05)
	style_panel_problema.border_color = PALETA_BORDE_NEGRO 
	style_panel_problema.border_width_left = 4
	style_panel_problema.border_width_right = 4
	style_panel_problema.border_width_top = 4
	style_panel_problema.border_width_bottom = 4
	style_panel_problema.corner_radius_top_left = 15
	style_panel_problema.corner_radius_top_right = 15
	style_panel_problema.corner_radius_bottom_left = 15
	style_panel_problema.corner_radius_bottom_right = 15
	style_panel_problema.content_margin_left = 30
	style_panel_problema.content_margin_right = 30
	style_panel_problema.content_margin_top = 20
	style_panel_problema.content_margin_bottom = 20
	style_panel_problema.shadow_color = Color(0, 0, 0, 0.4)
	style_panel_problema.shadow_size = 5
	style_panel_problema.shadow_offset = Vector2(3, 3)

	_campo_operandos.add_theme_stylebox_override("normal", style_panel_problema)
	_campo_operandos.add_theme_color_override("font_color", PALETA_GLIFO_TEXTO)
	_campo_operandos.add_theme_font_size_override("font_size", 50)
	_campo_operandos.add_theme_constant_override("line_spacing", -5)
	_campo_operandos.add_theme_constant_override("outline_size", 2)
	_campo_operandos.add_theme_color_override("font_outline_color", PALETA_BORDE_NEGRO)
	_campo_operandos.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_generar_problema()

func _crear_contador_aciertos() -> void:
	label_aciertos = Label.new()
	label_aciertos.name = "LabelAciertos"
	add_child(label_aciertos)

	var style_aciertos = StyleBoxFlat.new()
	style_aciertos.bg_color = PALETA_PIEDRA_FONDO
	style_aciertos.border_color = PALETA_ACENTO_TURQUESA
	style_aciertos.border_width_left = 4
	style_aciertos.border_width_right = 4
	style_aciertos.border_width_top = 4
	style_aciertos.border_width_bottom = 4
	style_aciertos.corner_radius_top_left = 10
	style_aciertos.corner_radius_top_right = 10
	style_aciertos.corner_radius_bottom_left = 10
	style_aciertos.corner_radius_bottom_right = 10
	style_aciertos.content_margin_left = 20
	style_aciertos.content_margin_right = 20
	style_aciertos.content_margin_top = 10
	style_aciertos.content_margin_bottom = 10
	style_aciertos.shadow_color = Color(0, 0, 0, 0.4)
	style_aciertos.shadow_size = 4
	style_aciertos.shadow_offset = Vector2(2, 2)

	label_aciertos.add_theme_stylebox_override("normal", style_aciertos)
	label_aciertos.add_theme_color_override("font_color", PALETA_GLIFO_TEXTO)
	label_aciertos.add_theme_font_size_override("font_size", 28)
	label_aciertos.add_theme_constant_override("outline_size", 2)
	label_aciertos.add_theme_color_override("font_outline_color", PALETA_BORDE_NEGRO)
	label_aciertos.position = Vector2(25, 25)

	_actualizar_texto_aciertos()

func _crear_label_error() -> void:
	label_error_dinero = Label.new()
	label_error_dinero.name = "LabelErrorDinero"
	label_error_dinero.text = "¡No tienes suficientes monedas!"
	label_error_dinero.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_error_dinero.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label_error_dinero.add_theme_font_size_override("font_size", 32)
	label_error_dinero.add_theme_color_override("font_color", PALETA_ACENTO_ROJO)
	label_error_dinero.add_theme_constant_override("outline_size", 3)
	label_error_dinero.add_theme_color_override("font_outline_color", PALETA_BORDE_NEGRO)
	label_error_dinero.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	label_error_dinero.position.y -= 80
	label_error_dinero.hide()
	add_child(label_error_dinero)

func _actualizar_texto_aciertos() -> void:
	if label_aciertos:
		label_aciertos.text = "Aciertos: " + str(correctos) + " / " + str(ACIERTOS_OBJETIVO)
	
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
	
	return style

func _crear_botones() -> void:
	if not _contenedor_botones: 
		push_error("Contenedor de botones no seleccionado")
		return
		
	var tamano_boton := Vector2(100, 100)
	var tamano_fuente := 32
	
	var style_normal = _crear_estilo_boton_piedra_maya(PALETA_PIEDRA_FONDO)
	var style_hover = _crear_estilo_boton_piedra_maya(PALETA_PIEDRA_FONDO, true)
	var style_pressed = _crear_estilo_boton_piedra_maya(PALETA_PIEDRA_FONDO.darkened(0.1))
	
	for caracter in "1234567890":
		if caracter.is_empty(): continue
		
		var btn := Button.new()
		btn.set_text(caracter)
		btn.custom_minimum_size = tamano_boton
		btn.add_theme_font_size_override("font_size", tamano_fuente)
		
		btn.add_theme_stylebox_override("normal", style_normal)
		btn.add_theme_stylebox_override("hover", style_hover)
		btn.add_theme_stylebox_override("pressed", style_pressed)
		btn.add_theme_color_override("font_color", PALETA_GLIFO_TEXTO)
		btn.add_theme_color_override("font_hover_color", PALETA_ACENTO_TURQUESA)
		btn.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
		btn.add_theme_constant_override("outline_size", 2)
		btn.add_theme_color_override("font_outline_color", PALETA_BORDE_NEGRO)

		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		btn.pressed.connect(func(): colocar_caracter.emit(caracter))
		_contenedor_botones.add_child(btn)
	
	var btn_del := Button.new()
	btn_del.set_text("DEL")
	btn_del.custom_minimum_size = tamano_boton
	btn_del.add_theme_font_size_override("font_size", tamano_fuente)
	btn_del.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_del.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	btn_del.add_theme_stylebox_override("normal", style_normal)
	btn_del.add_theme_stylebox_override("hover", style_hover)
	btn_del.add_theme_stylebox_override("pressed", style_pressed)
	btn_del.add_theme_color_override("font_color", PALETA_GLIFO_TEXTO)
	btn_del.add_theme_color_override("font_hover_color", PALETA_ACENTO_TURQUESA)
	btn_del.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
	btn_del.add_theme_constant_override("outline_size", 2)
	btn_del.add_theme_color_override("font_outline_color", PALETA_BORDE_NEGRO)

	btn_del.pressed.connect(func(): eliminar_caracter.emit())
	_contenedor_botones.add_child(btn_del)

func _generar_problema() -> bool:
	randomize()
	_operador = OPERADOR
	_operandos = []
	
	var num1 := randi_range(0, 99)
	var num2 := randi_range(0, 99)
	
	if num2 > num1:
		var temp = num1
		num1 = num2
		num2 = temp
		
	_operandos.push_back(num1)
	_operandos.push_back(num2)
	
	var respuesta = num1 - num2
	_respuesta_correcta = str(respuesta)
	
	return _actualizar_ui() 

func _actualizar_ui() -> bool:
	_campo_operandos.text = ""
	for operando in _operandos:
		_campo_operandos.text += (str(operando)  + '\n' + _operador + '\n')
	
	_campo_operandos.text = _campo_operandos.text.left(-3)
	_campo_respuesta.clear()
	return true

func _on_colocar_caracter(caracter: String) -> void:
	_campo_respuesta.text += caracter

func _on_eliminar_caracter() -> void:
	_campo_respuesta.text = _campo_respuesta.text.left(-1)

func _on_comprobar_respuesta(respuesta: String) -> void:
	if respuesta.is_empty():
		return 
	if int(respuesta) == int(_respuesta_correcta):
		_es_respuesta_correcta()
	else:
		_es_respuesta_incorrecta()

func _es_respuesta_correcta() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	get_tree().root.add_child(canvas)
	
	var color_rect := ColorRect.new()
	color_rect.color = Color(0.2, 0.8, 0.3, 0.0)
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(color_rect)
	
	var contenedor := CenterContainer.new()
	contenedor.set_anchors_preset(PRESET_FULL_RECT)
	canvas.add_child(contenedor)
	
	var label := Label.new()
	label.text = "¡CORRECTO!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_color_override("font_outline_color", Color(0, 0.3, 0))
	label.modulate = Color(1, 1, 1, 0)
	contenedor.add_child(label)
	
	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(color_rect, "color:a", 0.3, 0.3)
	tween.tween_property(color_rect, "color:a", 0.0, 0.82).set_delay(0.5)
	
	tween.tween_property(label, "modulate:a", 1.0, 0.3)
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.3).set_delay(0.2)
	tween.tween_property(label, "modulate:a", 0.0, 0.3).set_delay(0.7)
	
	await tween.finished
	
	_aumentar_aciertos()
	canvas.queue_free()
	_generar_problema()

func _aumentar_aciertos() -> int:
	correctos += 1
	_actualizar_texto_aciertos()
	if correctos >= ACIERTOS_OBJETIVO:
		_mostrar_recompensas()
	return correctos

func _es_respuesta_incorrecta() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	get_tree().root.add_child(canvas)
	
	var color_rect := ColorRect.new()
	color_rect.color = Color(0.588, 0.11, 0.344, 0.0)
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(color_rect)
	
	var contenedor := CenterContainer.new()
	contenedor.set_anchors_preset(PRESET_FULL_RECT)
	canvas.add_child(contenedor)
	
	var label := Label.new()
	label.text = "¡INCORRECTO!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_color_override("font_outline_color", Color(0.433, 0.109, 0.105, 1.0))
	label.modulate = Color(1, 1, 1, 0)
	contenedor.add_child(label)
	
	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(color_rect, "color:a", 0.3, 0.3)
	tween.tween_property(color_rect, "color:a", 0.0, 0.82).set_delay(0.5)
	
	tween.tween_property(label, "modulate:a", 1.0, 0.3)
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.3).set_delay(0.2)
	tween.tween_property(label, "modulate:a", 0.0, 0.3).set_delay(0.7)
	
	await tween.finished
	
	canvas.queue_free()
	_generar_problema()
	
func _mostrar_recompensas():
	$fondos2.hide()
	_texture_fondo_mayor.modulate = Color(0.5, 0.5, 0.5) 
	if contenedor_objetos:
		contenedor_objetos.show()

# --- LÓGICA DE COMPRA Y SELECCIÓN MODIFICADA ---
func _seleccionar_objeto(objeto_elegido: String) -> void:
	# Check si ya está desbloqueada
	var ya_desbloqueada: bool = GameManager.armasDesbloqueadas.get(objeto_elegido, false)
	var costo: int = PRECIOS.get(objeto_elegido, 0)

	if ya_desbloqueada:
		_equipar_y_avanzar(objeto_elegido)
	else:
		# Intenta realizar el gasto de monedas
		if GameManager.gastar_monedas(costo):
			GameManager.desbloquear_arma(objeto_elegido)
			_equipar_y_avanzar(objeto_elegido)
		else:
			_mostrar_error_dinero()

func _mostrar_error_dinero() -> void:
	if label_error_dinero:
		label_error_dinero.show()
		var timer := get_tree().create_timer(2.0)
		await timer.timeout
		label_error_dinero.hide()

func _equipar_y_avanzar(objeto_elegido: String) -> void:
	print("Quitzal ha obtenido/equipado: ", objeto_elegido)
	
	# 1. Registrar arma en el GameManager
	GameManager.arma_equipada_actual = objeto_elegido
	if GameManager.has_signal("arma_cambiada"):
		GameManager.arma_cambiada.emit()

	# 2. Asignar el enum correspondiente al jugador si está en escena
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		match objeto_elegido:
			"flauta":
				jugador.objetoActual = jugador.OBJETOS.FLAUTA
			"hacha":
				jugador.objetoActual = jugador.OBJETOS.HACHA
			"lanza":
				jugador.objetoActual = jugador.OBJETOS.LANZA

	# 3. Transición al jefe
	get_tree().change_scene_to_file("res://niveles/nivel2/batalla_jabali.tscn")
