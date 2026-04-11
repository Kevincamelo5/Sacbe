extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body is Jugador:
		get_tree().change_scene_to_file("res://niveles/nivel1/nivel1_sumador2.tscn")
	pass # Replace with function body.
