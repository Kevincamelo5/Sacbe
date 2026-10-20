extends Control

# Nodos de la escena (Asegúrate de que los nombres coincidan con los de tu escena)
@onready var fondo: ColorRect = $ColorRect if has_node("ColorRect") else null
@onready var label_mensaje: Label = $Label if has_node("Label") else null
@onready var boton_menu: Button = $"HBoxContainer/Sí" if has_node("HBoxContainer/Sí") else $VolverMenu
@onready var boton_reiniciar: Button = $HBoxContainer/No if has_node("HBoxContainer/No") else $ReiniciarNivel

func _ready() -> void:
	# Asegurarse de que el juego no permanezca pausado si venía de estarlo
	get_tree().paused = false
	
	# Cambiar el texto del botón desde código para que diga "Reiniciar nivel"
	if boton_reiniciar:
		boton_reiniciar.text = "Reiniciar nivel"
	
	_estilizar_pantalla_muerte()

func _estilizar_pantalla_muerte() -> void:
	# 1. Fondo rojizo/oscuro místico (efecto de derrota en la selva)
	if fondo:
		fondo.color = Color(0.008, 0.141, 0.031, 0.584) # Rojo/marrón muy oscuro

	# 2. Estilo de botones tipo piedra con detalles dorados/rojizos
	var estilo_btn_normal := StyleBoxFlat.new()
	estilo_btn_normal.bg_color = Color(0.15, 0.08, 0.08, 0.85) # Fondo piedra oscuro
	estilo_btn_normal.border_color = Color(0.70, 0.40, 0.20, 0.8) # Cobre / Dorado tenue
	estilo_btn_normal.set_border_width_all(2)
	estilo_btn_normal.set_corner_radius_all(4)
	estilo_btn_normal.content_margin_left = 15
	estilo_btn_normal.content_margin_right = 15
	estilo_btn_normal.content_margin_top = 8
	estilo_btn_normal.content_margin_bottom = 8

	var estilo_btn_hover := estilo_btn_normal.duplicate() as StyleBoxFlat
	estilo_btn_hover.bg_color = Color(0.35, 0.15, 0.10, 0.95) # Rojo/dorado cálido al pasar el cursor
	estilo_btn_hover.border_color = Color(1.0, 0.75, 0.30, 1.0) # Borde brillante

	var estilo_btn_pressed := estilo_btn_hover.duplicate() as StyleBoxFlat
	estilo_btn_pressed.bg_color = Color(0.50, 0.20, 0.12, 1.0)

	var lista_botones = [boton_menu, boton_reiniciar]

	for btn in lista_botones:
		if btn:
			btn.add_theme_stylebox_override("normal", estilo_btn_normal)
			btn.add_theme_stylebox_override("hover", estilo_btn_hover)
			btn.add_theme_stylebox_override("pressed", estilo_btn_pressed)
			btn.add_theme_stylebox_override("focus", estilo_btn_hover)

			# Colores de fuente
			btn.add_theme_color_override("font_color", Color(0.92, 0.85, 0.75))
			btn.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.70))
			btn.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0))

	# 3. Color del mensaje principal
	if label_mensaje:
		label_mensaje.add_theme_color_override("font_color", Color(0.95, 0.88, 0.78))

# --- Botones de Acción ---

# Botón para volver al menú principal
func _on_sí_pressed() -> void:
	get_tree().change_scene_to_file("res://interfaz/menus/menu_principal.tscn")

# Botón para reiniciar nivel
func _on_no_pressed() -> void:
	# Reiniciamos el nivel en el que se encontraba el jugador (no siempre el nivel 1)
	if GameManager:
		GameManager.reiniciar_nivel()
	else:
		get_tree().change_scene_to_file("res://niveles/nivel1/nivel1_parte1.tscn")
