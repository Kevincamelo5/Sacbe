extends Control

signal comprobar_respuesta(String)
signal colocar_caracter(String)
signal eliminar_caracter

const COLOR_FONDO := Color(0.392, 0.435, 0.465, 1.0)
const COLOR_FONDO_BOTONES := Color(0.036, 0.0, 0.339, 0.914)
const TEX_FONDO_PROBLEMA := preload("res://icon.svg") 
const OPERADOR := "+"

#conexion de las funciones con sus respectivas terminales.
@onready var _contenedor_botones: GridContainer = $fondos2/derecha/CenterContainer/GridContainer
@onready var _campo_respuesta: LineEdit = $fondos2/izquierda/CenterContainer/VBoxContainer/LineEdit
@onready var _campo_operandos: Label = $fondos2/izquierda/CenterContainer/VBoxContainer/Label
@onready var _boton_enviar: Button = $fondos2/izquierda/MarginContainer/CenterContainer/BotonEnviar

var _operador:= '+'
var _operandos:= []
var _respuesta_correcta := "0"

#contador de correctos
var correctos:= 0

func _ready() -> void:
	
	_crear_botones()
	
	self.colocar_caracter.connect(_on_colocar_caracter)
	self.eliminar_caracter.connect(_on_eliminar_caracter)
	self.comprobar_respuesta.connect(_on_comprobar_respuesta)
	
	_boton_enviar.pressed.connect(func(): comprobar_respuesta.emit(_campo_respuesta.get_text()))
	
	_generar_problema()

func _crear_botones() -> void:
	if not _contenedor_botones: 
		push_error("Contenedor de botones no seleccionado")
		return
	
	for caracter in "1234567890":
		if caracter.is_empty(): continue
		
		var btn := Button.new()
		btn.set_text(caracter)
		
		btn.pressed.connect(func(): colocar_caracter.emit(caracter))
		
		_contenedor_botones.add_child(btn)
	
	
	var btn_del := Button.new()
	btn_del.set_text("DEL")
	
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
		_campo_operandos.text += (str(operando) + '\n' + _operador)
	
	_campo_operandos.text = _campo_operandos.text.left(-2)
	
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
		get_tree().change_scene_to_file("res://mapa/nivel1/nivel1_parte2.tscn")
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
