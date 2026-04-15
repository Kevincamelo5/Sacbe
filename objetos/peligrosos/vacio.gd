extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Jugador:
		var game_manager = get_node("%GameManager")
		if game_manager:
			game_manager.disminuir_vida()
