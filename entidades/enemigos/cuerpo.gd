extends Hurtbox # Heredamos la identidad para no tener que crear la clase de nuevo

# Eliminamos la línea "class_name Hurtbox"

# Usamos float por si tu clase original de Hurtbox lo requiere (como vimos antes)
func lastimar(cantidad_daño: float) -> void:
	
	if get_parent().has_method("recibir_daño"):
		# ¡Le pasamos la cantidad de daño dentro de los paréntesis!
		get_parent().recibir_daño(int(cantidad_daño))
