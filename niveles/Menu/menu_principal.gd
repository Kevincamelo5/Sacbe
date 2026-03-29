extends  Control


func _on_play_pressed() -> void:
	$"Musica de fondo".stop()
	$"Click".play()
	get_tree().change_scene_to_file("res://Cinematica inicial.tscn")
	pass # Replace with function body.


func _on_opciones_pressed() -> void:
	$"Musica de fondo".stop()
	$"Click".play()
	pass # Replace with function body.


func _on_creditos_pressed() -> void:
	$"Musica de fondo".stop()
	$"Click".play()
	get_tree().change_scene_to_file("res://creditos.tscn")
	pass # Replace with function body.


func _on_salir_pressed() -> void:
	$"Musica de fondo".stop()
	$Salir.play()
	get_tree().quit()
	pass


func _on_cargar_partida_pressed() -> void:
	$"Musica de fondo".stop()
	get_tree().change_scene_to_file("res://mapa/pruebas.tscn")
	pass # Replace with function body.
