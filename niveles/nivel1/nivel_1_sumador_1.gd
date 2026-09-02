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
const OPERADOR := "+"

#conexion de las funciones con sus respectivas terminales.

@onready var _contenedor_botones: GridContainer = $fondos2/derecha/CenterContainer/GridContainer
@onready var _campo_respuesta: LineEdit = $fondos2/izquierda/CenterContainer/VBoxContainer/LineEdit
@onready var _campo_operandos: Label = $fondos2/izquierda/CenterContainer/VBoxContainer/Label
@onready var _boton_enviar: Button = $fondos2/izquierda/MarginContainer/CenterContainer/BotonEnviar

@onready var _texture_fondo_mayor: TextureRect = $TextureRect

var _operador:= '+'
var _operandos:= []
var _respuesta_correcta := "0"

#contador de correctos
var correctos:= 0

func _ready() -> void:
	
	if not _texture_fondo_mayor:
		_texture_fondo_mayor = TextureRect.new()
		_texture_fondo_mayor.name = "TextureRectFondoMayor"
		add_child(_texture_fondo_mayor)
		move_child(_texture_fondo_mayor, 0) # Asegurar que esté detrás de todo

	_texture_fondo_mayor.texture = TEX_FONDO_PROBLEMA
	_texture_fondo_mayor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_texture_fondo_mayor.stretch_mode = TextureRect.STRETCH_SCALE
	_texture_fondo_mayor.set_anchors_preset(Control.PRESET_FULL_RECT)

	var margins_centrales := 100 # Margen para el octágono
	$fondos2.set_anchors_preset(Control.PRESET_FULL_RECT)
	$fondos2.add_theme_constant_override("margin_left", margins_centrales)
	$fondos2.add_theme_constant_override("margin_right", margins_centrales)
	$fondos2.add_theme_constant_override("margin_top", margins_centrales + 50) # Más espacio arriba por jaguares
	$fondos2.add_theme_constant_override("margin_bottom", margins_centrales)

	# --- CREACIÓN DE ESTILOS DE BOTONES ---
	_crear_botones()
	
	self.colocar_caracter.connect(_on_colocar_caracter)
	self.eliminar_caracter.connect(_on_eliminar_caracter)
	self.comprobar_respuesta.connect(_on_comprobar_respuesta)
	
	# Estilo para el botón Enviar (personalizado)
	var style_enviar_normal = _crear_estilo_boton_piedra_maya(PALETA_ACENTO_TURQUESA)
	var style_enviar_hover = _crear_estilo_boton_piedra_maya(PALETA_ACENTO_TURQUESA, true)
	var style_enviar_pressed = _crear_estilo_boton_piedra_maya(PALETA_ACENTO_AZUL)

	for estilo in [style_enviar_normal, style_enviar_hover, style_enviar_pressed]:
		estilo.content_margin_left = 20   # Margen izquierdo interno
		estilo.content_margin_right = 20  # Margen derecho interno
		estilo.content_margin_top = 15    # Margen superior interno
		estilo.content_margin_bottom = 15 # Margen inferior interno

	_boton_enviar.add_theme_stylebox_override("normal", style_enviar_normal)
	_boton_enviar.add_theme_stylebox_override("hover", style_enviar_hover)
	_boton_enviar.add_theme_stylebox_override("pressed", style_enviar_pressed)
	_boton_enviar.add_theme_color_override("font_color", PALETA_PIEDRA_FONDO)
	_boton_enviar.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	_boton_enviar.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
	_boton_enviar.add_theme_font_size_override("font_size", 45)

	# Contorno tallado
	_boton_enviar.add_theme_constant_override("outline_size", 2)
	_boton_enviar.add_theme_color_override("font_outline_color", PALETA_BORDE_NEGRO)
	_boton_enviar.pressed.connect(func(): comprobar_respuesta.emit(_campo_respuesta.get_text()))
	
	# --- ESTILOS DE LOS CAMPOS DE TEXTO ---
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
	
	# Contorno tallado
	_campo_respuesta.add_theme_constant_override("outline_size", 2)
	_campo_respuesta.add_theme_color_override("font_outline_color", PALETA_BORDE_NEGRO)

	var style_panel_problema = StyleBoxFlat.new()
	style_panel_problema.bg_color = PALETA_PIEDRA_FONDO.darkened(0.05) # Piedra oscura
	style_panel_problema.border_color = PALETA_BORDE_NEGRO 
	style_panel_problema.border_width_left = 4
	style_panel_problema.border_width_right = 4
	style_panel_problema.border_width_top = 4
	style_panel_problema.border_width_bottom = 4
	style_panel_problema.corner_radius_top_left = 15
	style_panel_problema.corner_radius_top_right = 15
	style_panel_problema.corner_radius_bottom_left = 15

	style_panel_problema.corner_radius_bottom_right = 15

	# Márgenes internos para que los números respiren y no peguen al borde

	style_panel_problema.content_margin_left = 30

	style_panel_problema.content_margin_right = 30

	style_panel_problema.content_margin_top = 20

	style_panel_problema.content_margin_bottom = 20

	# Sombra

	style_panel_problema.shadow_color = Color(0, 0, 0, 0.4)

	style_panel_problema.shadow_size = 5

	style_panel_problema.shadow_offset = Vector2(3, 3)


	_campo_operandos.add_theme_stylebox_override("normal", style_panel_problema)

	_campo_operandos.add_theme_color_override("font_color", PALETA_GLIFO_TEXTO)

	_campo_operandos.add_theme_font_size_override("font_size", 50) # Un poco más grande

	_campo_operandos.add_theme_constant_override("line_spacing", -5)

	_campo_operandos.add_theme_constant_override("outline_size", 2)

	_campo_operandos.add_theme_color_override("font_outline_color", PALETA_BORDE_NEGRO)

	_campo_operandos.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER # Centrar texto


	_generar_problema()

	

func _crear_estilo_boton_piedra_maya(accent_color: Color = PALETA_PIEDRA_FONDO, is_hover: bool = false) -> StyleBoxFlat:

	var style = StyleBoxFlat.new()

	style.bg_color = accent_color

	style.border_color = PALETA_BORDE_NEGRO

	style.border_width_left = 4

	style.border_width_right = 4

	style.border_width_top = 4

	style.border_width_bottom = 4

	# Esquinas ligeramente angulares para combinar con el marco octogonal

	style.corner_radius_top_left = 15

	style.corner_radius_top_right = 15

	style.corner_radius_bottom_left = 15

	style.corner_radius_bottom_right = 15

	# Bisel para efecto tallado

	style.draw_center = true

	if accent_color == PALETA_PIEDRA_FONDO:

		# Botones numéricos con degradado de piedra

		style.set_bg_color(PALETA_PIEDRA_FONDO.lightened(0.05))

		style.bg_color = PALETA_PIEDRA_FONDO

	else:

		# Botones de acento con degradado de color

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

		

	# Definimos el tamaño que queremos para todos (Ancho, Alto)

	var tamano_boton := Vector2(100, 100)

	# Definimos el tamaño de la letra

	var tamano_fuente := 32

	

	# Estilos para los botones numéricos y DEL (piedra con borde negro)

	var style_normal = _crear_estilo_boton_piedra_maya(PALETA_PIEDRA_FONDO)

	var style_hover = _crear_estilo_boton_piedra_maya(PALETA_PIEDRA_FONDO, true)

	var style_pressed = _crear_estilo_boton_piedra_maya(PALETA_PIEDRA_FONDO.darkened(0.1))

	

	for caracter in "1234567890":

		if caracter.is_empty(): continue

		

		var btn := Button.new()

		btn.set_text(caracter)

		

		# --- CONFIGURACIÓN DE TAMAÑO Y ESTILO ---

		btn.custom_minimum_size = tamano_boton

		btn.add_theme_font_size_override("font_size", tamano_fuente)

		

		# Aplicar estilos

		btn.add_theme_stylebox_override("normal", style_normal)

		btn.add_theme_stylebox_override("hover", style_hover)

		btn.add_theme_stylebox_override("pressed", style_pressed)

		# Texto marrón con contorno tallado

		btn.add_theme_color_override("font_color", PALETA_GLIFO_TEXTO)

		btn.add_theme_color_override("font_hover_color", PALETA_ACENTO_TURQUESA)

		btn.add_theme_color_override("font_pressed_color", Color(1, 1, 1))

		btn.add_theme_constant_override("outline_size", 2)

		btn.add_theme_color_override("font_outline_color", PALETA_BORDE_NEGRO)


		# Esto hace que el botón se estire para llenar su celda en el Grid

		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL

		

		btn.pressed.connect(func(): colocar_caracter.emit(caracter))

		

		_contenedor_botones.add_child(btn)

	

	var btn_del := Button.new()

	btn_del.set_text("DEL")

	

	# Aplicamos el mismo tamaño y estilo

	btn_del.custom_minimum_size = tamano_boton

	btn_del.add_theme_font_size_override("font_size", tamano_fuente)

	btn_del.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	btn_del.size_flags_vertical = Control.SIZE_EXPAND_FILL

	

	btn_del.add_theme_stylebox_override("normal", style_normal)

	btn_del.add_theme_stylebox_override("hover", style_hover)

	btn_del.add_theme_stylebox_override("pressed", style_pressed)

	# Texto marrón con contorno tallado

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

	

	var respuesta : int = 0

	for i in 2:

		var num := randi_range(0, 99)

		_operandos.push_back(num)

		respuesta += num

	

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

	if respuesta == _respuesta_correcta:

		print("Respuesta correcta")

		_es_respuesta_correcta()

	else:

		print("Respuesta incorrecta")

		_es_respuesta_incorrecta()


func _es_respuesta_correcta() -> void:

	# Crear canvas layer para el efecto

	var canvas := CanvasLayer.new()

	canvas.layer = 100  # Alta prioridad para que esté por encima de todo

	get_tree().root.add_child(canvas)

	

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

	_generar_problema()


func _aumentar_aciertos() -> int:

	correctos += 1

	print(correctos)

	if correctos >= 5:

		get_tree().change_scene_to_file("res://niveles/nivel1/nivel1_parte2.tscn")

	return correctos


func _es_respuesta_incorrecta() -> void:

	# Crear canvas layer para el efecto

	var canvas := CanvasLayer.new()

	canvas.layer = 100  # Alta prioridad para que esté por encima de todo

	get_tree().root.add_child(canvas)

	

	# Crear fondo semitransparente verde

	var color_rect := ColorRect.new()

	color_rect.color = Color(0.588, 0.11, 0.344, 0.0)  # Verde más suave

	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)

	canvas.add_child(color_rect)

	

	# Crear centrador del texto

	var contenedor := CenterContainer.new()

	contenedor.set_anchors_preset(PRESET_FULL_RECT)

	canvas.add_child(contenedor)

	

	# Crear mensaje de éxito

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
	_generar_problema() 
