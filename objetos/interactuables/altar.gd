extends Node2D

@export_file("*.tscn") var next_scene_path: String

@onready var sprite: Sprite2D = $Area2D/Sprite2D if has_node("Area2D/Sprite2D") else null
@onready var area_2d: Area2D = $Area2D if has_node("Area2D") else null

var _animacion_brillo: Tween

func _ready() -> void:
	_iniciar_efecto_pulso()

# --- EFECTO DE BRILLO EN PULSOS ---
func _iniciar_efecto_pulso() -> void:
	if not sprite:
		return
	
	_animacion_brillo = create_tween().set_loops()
	_animacion_brillo.tween_property(sprite, "modulate", Color(1.4, 1.3, 0.8, 1.0), 1.2).set_trans(Tween.TRANS_SINE)
	_animacion_brillo.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.2).set_trans(Tween.TRANS_SINE)

# --- DETECCIÓN DEL JUGADOR ---
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador") or body.name == "Jugador" or body.get("class_name") == "Jugador":
		_mostrar_mensaje_mision()

func _mostrar_mensaje_mision() -> void:
	# Pausamos el juego
	get_tree().paused = true
	
	# Creamos el CanvasLayer que procesa en pausa
	var canvas_layer := CanvasLayer.new()
	canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas_layer)
	
	# Contenedor principal a pantalla completa para centrar
	var control_raiz := Control.new()
	control_raiz.process_mode = Node.PROCESS_MODE_ALWAYS
	control_raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(control_raiz)
	
	# Panel de la ventana (Estela de piedra)
	var panel := PanelContainer.new()
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Estilo visual
	var estilo_panel := StyleBoxFlat.new()
	estilo_panel.bg_color = Color(0.12, 0.10, 0.08, 0.95)
	estilo_panel.border_color = Color(0.85, 0.70, 0.35, 1.0) # Borde dorado
	estilo_panel.set_border_width_all(3)
	estilo_panel.set_corner_radius_all(8)
	estilo_panel.content_margin_left = 30
	estilo_panel.content_margin_right = 30
	estilo_panel.content_margin_top = 25
	estilo_panel.content_margin_bottom = 25
	panel.add_theme_stylebox_override("panel", estilo_panel)
	
	# Centrado en Godot 4
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	control_raiz.add_child(panel)
	
	# Layout vertical de contenido
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 18)
	panel.add_child(vbox)
	
	# Texto del mensaje centrado
	var label := Label.new()
	label.text = "Resuelve 5 operaciones para obtener una recompensa\ny seguir avanzando"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(0.95, 0.88, 0.75))
	vbox.add_child(label)
	
	# Botón para aceptar
	var btn_aceptar := Button.new()
	btn_aceptar.text = "Aceptar"
	btn_aceptar.process_mode = Node.PROCESS_MODE_ALWAYS
	
	var estilo_btn_normal := StyleBoxFlat.new()
	estilo_btn_normal.bg_color = Color(0.25, 0.20, 0.12, 0.9)
	estilo_btn_normal.border_color = Color(0.80, 0.65, 0.30, 1.0)
	estilo_btn_normal.set_border_width_all(2)
	estilo_btn_normal.set_corner_radius_all(4)
	estilo_btn_normal.content_margin_top = 8
	estilo_btn_normal.content_margin_bottom = 8

	var estilo_btn_hover := estilo_btn_normal.duplicate() as StyleBoxFlat
	estilo_btn_hover.bg_color = Color(0.40, 0.32, 0.16, 1.0)
	estilo_btn_hover.border_color = Color(1.0, 0.88, 0.45, 1.0)

	btn_aceptar.add_theme_stylebox_override("normal", estilo_btn_normal)
	btn_aceptar.add_theme_stylebox_override("hover", estilo_btn_hover)
	btn_aceptar.add_theme_stylebox_override("focus", estilo_btn_hover)
	btn_aceptar.add_theme_color_override("font_color", Color(1.0, 0.95, 0.80))
	
	# Acción del botón
	btn_aceptar.pressed.connect(func():
		get_tree().paused = false
		change_scene()
	)
	
	vbox.add_child(btn_aceptar)

func change_scene() -> void:
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("Error: ruta next_scene_path no encontrada")
