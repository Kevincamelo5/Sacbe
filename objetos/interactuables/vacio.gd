extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Jugador:
		get_tree().reload_current_scene()
