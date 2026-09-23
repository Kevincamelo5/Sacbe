extends Hurtbox # Cambiamos Area2D por Hurtbox para heredar su identidad

# Eliminamos la línea "class_name Hurtbox" para evitar el choque de nombres

# Esta es la función que llama tu jugador al atacar
func lastimar(cantidad_dano: int) -> void:
	# Verificamos si el nodo padre (el CharacterBody2D del Jabalí) tiene la función
	if get_parent().has_method("recibir_dano"):
		# Le pasamos el daño recibido al jabalí
		get_parent().recibir_dano(cantidad_dano)
