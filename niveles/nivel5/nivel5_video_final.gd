extends Control
## Escena final del Nivel 5: reproduce el video "Video batalla final.mp4"
## y muestra un botón "Finalizar" que regresa al menú principal.
## Si el video termina, también se regresa al menú automáticamente.

@onready var video: VideoStreamPlayer = $VideoStreamPlayer
@onready var boton_finalizar: Button = $Finalizar

func _ready() -> void:
	boton_finalizar.pressed.connect(_ir_al_inicio)
	video.finished.connect(_ir_al_inicio)
	if video.stream != null:
		video.play()

func _ir_al_inicio() -> void:
	get_tree().change_scene_to_file("res://interfaz/menus/menu_principal.tscn")
