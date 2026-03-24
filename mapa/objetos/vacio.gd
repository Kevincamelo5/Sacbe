extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jugador":
		get_tree().reload_current_scene()
	pass # Replace with function body.
