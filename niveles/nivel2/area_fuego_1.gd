extends Area2D

# Cuánta fuerza tendrá el empujón
@export var fuerza: float = 1000

func _on_body_entered(body):
	# Usamos el grupo "player" que ya habías configurado antes
	if body.is_in_group("player"):
		# 1. Calcular de qué lado está el jugador respecto al fuego
		var direccion_hacia_jugador = sign(body.global_position.x - global_position.x)
		
		# (Por si el jugador cae exactamente en el centro del píxel)
		if direccion_hacia_jugador == 0:
			direccion_hacia_jugador = 1.0 
			
		# 2. Comprobar si el jugador tiene la función y llamarla
		if body.has_method("recibir_empujon"):
			body.recibir_empujon(direccion_hacia_jugador, fuerza)
