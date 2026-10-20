extends Control
## Cinemática genérica: muestra una imagen de fondo con un botón "Continuar"
## que lleva a next_scene. Se usa en las transiciones del Nivel 5.

@export_file("*.tscn") var next_scene: String = ""

func _ready() -> void:
	var boton := get_node_or_null("Continuar")
	if boton:
		boton.pressed.connect(_avanzar)

func _avanzar() -> void:
	if next_scene != "":
		get_tree().change_scene_to_file(next_scene)
	else:
		push_error("cinematica.gd: next_scene no definido")
