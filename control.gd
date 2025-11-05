# Cinematica.gd
extends Control

@onready var video_player = $VideoStreamPlayer
@onready var skip_label = $SkipLabel

func _ready():
	# Conectar señales
	video_player.finished.connect(_on_video_finished)
	
	# Reproducir el video automáticamente
	video_player.play()

func _input(event):
	# Permitir saltar la cinemática con cualquier tecla o click
	if event is InputEventKey or event is InputEventMouseButton:
		if event.pressed:
			skip_cinematic()

func _on_video_finished():
	# Cambiar a la siguiente escena cuando termine el video
	cambiar_a_juego()

func skip_cinematic():
	video_player.stop()
	cambiar_a_juego()

func cambiar_a_juego():
	get_tree().change_scene_to_file("res://mapa/pruebas.tscn")
