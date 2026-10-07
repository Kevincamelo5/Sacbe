extends Hurtbox
class_name EnemyHurtbox

func lastimar(cantidad: float = 1.0) -> void:
	var padre = get_parent()
	if not padre:
		return

	if padre.has_method("recibir_daño"):
		padre.recibir_daño(int(cantidad))
	elif padre.has_method("recibir_dano"):
		padre.recibir_dano(cantidad)
