extends Control

# Nombres de tus nodos de botón en la escena (ajústalos si difieren)
@onready var boton_play = $ColorRect/VBoxContainer/play
@onready var boton_cargar = $ColorRect/VBoxContainer/cargar_partida
@onready var boton_opciones = $ColorRect/VBoxContainer/ayuda
@onready var boton_creditos = $ColorRect/VBoxContainer/creditos
@onready var boton_salir = $ColorRect/VBoxContainer/salir

func _ready() -> void:
	_estilizar_menu()

func _estilizar_menu() -> void:
	# 1. Crear estilo base (Piedra oscura con borde dorado tenue)
	var estilo_normal := StyleBoxFlat.new()
	estilo_normal.bg_color = Color(0.12, 0.10, 0.08, 0.6) # Tono café/piedra semitransparente
	estilo_normal.border_color = Color(0.75, 0.60, 0.32, 0.8) # Dorado antiguo
	estilo_normal.set_border_width_all(3)
	estilo_normal.set_corner_radius_all(4)
	estilo_normal.content_margin_left = 10
	estilo_normal.content_margin_right = 10
	estilo_normal.content_margin_top = 6
	estilo_normal.content_margin_bottom = 6

	# 2. Crear estilo al pasar el ratón (Glow dorado simulando el rayo de luz)
	var estilo_hover := estilo_normal.duplicate() as StyleBoxFlat
	estilo_hover.bg_color = Color(0.35, 0.28, 0.15, 0.75) # Iluminado por la luz
	estilo_hover.border_color = Color(1.0, 0.88, 0.45, 1.0) # Borde dorado brillante

	# 3. Crear estilo al hacer clic
	var estilo_pressed := estilo_hover.duplicate() as StyleBoxFlat
	estilo_pressed.bg_color = Color(0.5, 0.4, 0.18, 0.9)

	# 4. Agrupar botones para aplicarles los estilos y colores de fuente
	var lista_botones = [boton_play, boton_cargar, boton_opciones, boton_creditos, boton_salir]

	for boton in lista_botones:
		if boton:
			# Aplicar estilos de fondo
			boton.add_theme_stylebox_override("normal", estilo_normal)
			boton.add_theme_stylebox_override("hover", estilo_hover)
			boton.add_theme_stylebox_override("pressed", estilo_pressed)
			boton.add_theme_stylebox_override("focus", estilo_hover)
			
			# Aplicar colores del texto
			boton.add_theme_color_override("font_color", Color(0.92, 0.86, 0.73)) # Beige/Arena
			boton.add_theme_color_override("font_hover_color", Color(1.0, 0.96, 0.70)) # Texto brillante
			boton.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0))

# --- Funciones de interacción ---

func _on_play_pressed() -> void:
	$"Musica de fondo".stop()
	$"Click".play()
	await $"Click".finished
	get_tree().change_scene_to_file("res://interfaz/pantallas/Cinematica inicial.tscn")

func _on_cargar_partida_pressed() -> void:
	$"Musica de fondo".stop()
	get_tree().change_scene_to_file("res://niveles/nivel1/nivel1_parte1.tscn")

func _on_opciones_pressed() -> void:
	$"Musica de fondo".stop()
	$"Click".play()
	await $"Click".finished
	get_tree().change_scene_to_file("res://interfaz/pantallas/ayuda/ayuda.tscn")

func _on_creditos_pressed() -> void:
	$"Musica de fondo".stop()
	$"Click".play()
	await $"Click".finished
	get_tree().change_scene_to_file("res://interfaz/pantallas/creditos.tscn")

func _on_salir_pressed() -> void:
	$"Musica de fondo".stop()
	$"Click".play()
	if has_node("Salir"):
		$Salir.play()
	await $"Click".finished
	get_tree().quit()
