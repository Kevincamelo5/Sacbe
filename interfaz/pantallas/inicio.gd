extends CanvasLayer

func _on_timer_timeout()->void:
	$ProgressBar.value += 10
	
	if $ProgressBar.value >= $ProgressBar.max_value:
		get_tree().change_scene_to_file("res://niveles/Menu/menu_principal.tscn")
