class_name Hurtbox
extends Area2D

## Script universal para redirigir el impacto del arma al nodo padre (Enemigo)

func lastimar(cantidad: float = 1.0) -> void:
	var padre = get_parent()
	if not padre:
		return

	# Compatibilidad con Pájaro / Anima (recibir_daño con 'ñ')
	if padre.has_method("recibir_daño"):
		padre.recibir_daño(int(cantidad))
	# Compatibilidad con Jabalí (recibir_dano sin 'ñ')
	elif padre.has_method("recibir_dano"):
		padre.recibir_dano(cantidad)
	else:
		push_warning("El nodo padre " + padre.name + " no tiene función de daño definida.")
