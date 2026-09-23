class_name Hurtbox
extends Area2D

func lastimar(cantidad: float) -> void:
	# Busca al personaje padre (el Pájaro) y le aplica el daño
	var propietario = get_parent()
	if propietario and propietario.has_method("recibir_daño"):
		propietario.recibir_daño(int(cantidad))
