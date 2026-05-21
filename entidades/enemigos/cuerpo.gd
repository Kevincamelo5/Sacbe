extends Area2D
class_name Hurtbox


# Esta es la función que ejecuta acuchillar()
func lastimar(cantidad_daño: int) -> void:
	# Transfiere el daño al script principal del enemigo (anima.gd)
	if get_parent().has_method("recibir_daño"):
		get_parent().recibir_daño()
