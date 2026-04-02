extends Area2D

@export var next_scene_path: String

# Nueva función conectada a la señal "area_entered"
func _on_area_entered(area: Area2D) -> void:
	# Comprueba si el área que entró está en la capa (layer) de tu Hurtbox.
	# Cambia el '2' por el número de capa donde tienes configurado el Hurtbox del Jugador.
	if area.get_collision_layer_value(2):
		change_scene()

func change_scene() -> void:
	# Una buena práctica es verificar que la ruta no esté vacía antes de cambiar
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("Error: No se ha asignado una ruta para next_scene_path")


func _on_body_entered(body: Node2D) -> void:
	if body is Jugador:
		change_scene()
	pass # Replace with function body.
