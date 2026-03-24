extends CanvasLayer


func _on_izquierda_pressed() -> void:
	$Izquierda.modulate=Color(1,1,1,0.5)

func _on_izquierda_released() -> void:
	$Izquierda.modulate=Color(1,1,1,1)

func _on_derecha_pressed() -> void:
	$Derecha.modulate=Color(1,1,1,0.5) # Replace with function body.
	
func _on_derecha_released() -> void:
	$Derecha.modulate=Color(1,1,1,1) # Replace with function body.

func _on_saltar_pressed() -> void:
	$Saltar.modulate=Color(1,1,1,0.5) # Replace with function body.

func _on_saltar_released() -> void:
	$Saltar.modulate=Color(1,1,1,1) # Replace with function body.

func _on_agacharse_pressed() -> void:
	$Agacharse.modulate=Color(1,1,1,0.5) # Replace with function body.

func _on_agacharse_released() -> void:
	$Agacharse.modulate=Color(1,1,1,1) # Replace with function body.

func _on_pausa_pressed() -> void:
	$Pausa.modulate=Color(1,1,1,0.5) # Replace with function body.

func _on_pausa_released() -> void:
	$Pausa.modulate=Color(1,1,1,1) # Replace with function body.

func _on_cambiar_objeto_pressed() -> void:
	$CambiarObjeto.modulate=Color(1,1,1,0.5) # Replace with function body.

func _on_cambiar_objeto_released() -> void:
	$CambiarObjeto.modulate=Color(1,1,1,1) # Replace with function body.

func _on_usar_objeto_pressed() -> void:
	$UsarObjeto.modulate=Color(1,1,1,0.5) # Replace with function body.

func _on_usar_objeto_released() -> void:
	$UsarObjeto.modulate=Color(1,1,1,1) # Replace with function body.
