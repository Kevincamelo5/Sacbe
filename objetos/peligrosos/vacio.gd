extends Node2D




func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Jugador:
		get_tree().reload_current_scene()
	pass # Replace with function body.
