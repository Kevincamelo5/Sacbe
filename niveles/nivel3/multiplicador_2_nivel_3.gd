extends Control

# Referencias a tus nodos (Ajusta las rutas según tu árbol de nodos)
@onready var label_problema: Label = $VBoxContainer/LabelProblema
@onready var boton_1: Button = $VBoxContainer/HBoxContainer/Boton1
@onready var boton_2: Button = $VBoxContainer/HBoxContainer/Boton2
@onready var boton_3: Button = $VBoxContainer/HBoxContainer/Boton3

var respuesta_correcta: String = ""
var correctos: int = 0

func _ready() -> void:
	# Conectamos los botones a una misma función. 
	# Usamos bind() para que el botón se "envíe a sí mismo" y sepamos cuál se presionó.
	boton_1.pressed.connect(_on_boton_presionado.bind(boton_1))
	boton_2.pressed.connect(_on_boton_presionado.bind(boton_2))
	boton_3.pressed.connect(_on_boton_presionado.bind(boton_3))
	
	generar_problema()

func generar_problema() -> void:
	randomize()
	# Tiramos una moneda: 0 para fracciones, 1 para decimales
	var tipo_operacion = 1
	var opciones = []
	
	if tipo_operacion == 0:
		# --- LÓGICA DE FRACCIONES ---
		# Generamos numeradores y denominadores aleatorios
		var num1 = randi_range(1, 5)
		var den1 = randi_range(2, 5)
		var num2 = randi_range(1, 5)
		var den2 = randi_range(2, 5)
		
		# Mostramos en pantalla: Ej. "1/2 x 3/4"
		label_problema.text = str(num1) + "/" + str(den1) + " x " + str(num2) + "/" + str(den2)
		
		# Calculamos la respuesta real (numerador por numerador, denominador por denominador)
		var res_num = num1 * num2
		var res_den = den1 * den2
		respuesta_correcta = str(res_num) + "/" + str(res_den)
		opciones.append(respuesta_correcta)
		
		# Inventamos 2 opciones falsas sumando números aleatorios para confundir
		opciones.append(str(res_num + randi_range(1, 3)) + "/" + str(res_den))
		opciones.append(str(res_num) + "/" + str(res_den + randi_range(1, 3)))
		
	else:
		# --- LÓGICA DE DECIMALES ---
		# Dividimos entre 10.0 para crear decimales. Ej: 23 / 10.0 = 2.3
		var val1 = randi_range(11, 50) / 10.0
		var val2 = randi_range(2, 9) / 10.0
		
		label_problema.text = str(val1) + " x " + str(val2)
		
		# snapped() redondea a 2 decimales para evitar el clásico error de programación 
		var res_exacto = snapped(val1 * val2, 0.01)
		respuesta_correcta = str(res_exacto)
		opciones.append(respuesta_correcta)
		
		# Inventamos 2 opciones falsas modificando los decimales
		opciones.append(str(snapped(res_exacto + 0.12, 0.01)))
		opciones.append(str(snapped(res_exacto - 0.4, 0.01)))
		
	# --- LA MAGIA DEL MÚLTIPLE CHOICE ---
	# Mezclamos el arreglo para que la respuesta correcta no siempre caiga en el Boton 1
	opciones.shuffle()
	
	# Asignamos el texto mezclado a los botones
	boton_1.text = opciones[0]
	boton_2.text = opciones[1]
	boton_3.text = opciones[2]

func _on_boton_presionado(boton: Button) -> void:
	# Verificamos si el texto del botón presionado es igual a la respuesta guardada
	if boton.text == respuesta_correcta:
		print("¡Respuesta Correcta!")
		_es_respuesta_correcta()
	else:
		print("Respuesta Incorrecta")
		_es_respuesta_incorrecta()

# ==========================================================
# ANIMACIONES Y LÓGICA DE PROGRESIÓN (Tus funciones exactas)
# ==========================================================

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
