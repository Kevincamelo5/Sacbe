extends Control


func _ready() -> void:
	$Lizquierda.hide()
	$Lderecha.hide()
	$Lsaltar.hide()
	$Lcaer.hide()
	$Lpausa.hide()
	$Lcambiar.hide()
	$Latacar.hide()
	$AudioStreamPlayer.autoplay


func _on_izquierda_pressed() -> void:
	$Lizquierda.show()
	$Infoinicial.hide()

func _on_izquierda_released() -> void:
	$Lizquierda.hide()


func _on_derecha_pressed() -> void:
	$Lderecha.show()
	$Infoinicial.hide()


func _on_derecha_released() -> void:
	$Lderecha.hide()


func _on_saltar_pressed() -> void:
	$Lsaltar.show()
	$Infoinicial.hide()


func _on_agacharse_pressed() -> void:
	$Lcaer.show()
	$Infoinicial.hide()


func _on_saltar_released() -> void:
	$Lsaltar.hide()


func _on_agacharse_released() -> void:
	$Lcaer.hide()


func _on_pausa_pressed() -> void:
	$Lpausa.show()
	$Infoinicial.hide()


func _on_pausa_released() -> void:
	$Lpausa.hide()


func _on_cambiar_objeto_pressed() -> void:
	$Lcambiar.show()
	$Infoinicial.hide()


func _on_cambiar_objeto_released() -> void:
	$Lcambiar.hide()


func _on_usar_objeto_pressed() -> void:
	$Latacar.show()
	$Infoinicial.hide()


func _on_usar_objeto_released() -> void:
	$Latacar.hide() # Replace with function body.


func _on_button_pressed() -> void:
	$AudioStreamPlayer.stop()
	get_tree().change_scene_to_file("res://interfaz/menus/menu_principal.tscn")
