extends Node2D

func _on_area_2d_body_entered(body):
	if body.is_in_group("jugador"):
		# Le enviamos 'true' porque el daño SÍ fue por caer al vacío
		GameManager.disminuir_vida(true)
