extends Node2D

func _on_animation_player_animation_finished(anim_name: String) -> void:
	# Cambia esto por la ruta real de tu nivel donde vas a jugar
	get_tree().change_scene_to_file("res://niveles/nivel3/nivel3_parte2.tscn")
