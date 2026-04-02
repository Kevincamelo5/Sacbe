extends Node2D
@export var next_scene_path: String

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Jugador:
		change_scene()
	pass # Replace with function body.

func change_scene()->void:
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("Error: ruta next_scene_path no encontrada")
