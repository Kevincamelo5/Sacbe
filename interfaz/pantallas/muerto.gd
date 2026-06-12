extends Control



func _on_sí_pressed() -> void:
	get_tree().change_scene_to_file("res://interfaz/menus/menu_principal.tscn")
	pass # Replace with function body.


func _on_no_pressed() -> void:
	get_tree().change_scene_to_file("res://niveles/nivel1/nivel1_parte1.tscn")
	pass # Replace with function body.
