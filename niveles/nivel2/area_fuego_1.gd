extends Area2D

# Aumentamos la fuerza base para un empuje mucho más notable
@export var fuerza_empuje: float = 2000.0

func _on_body_entered(body):
	print("El fuego acaba de tocar a: ", body.name)
	
	if body.is_in_group("player"):
		
		
		if body.has_method("recibir_empujon"):
			
			var direccion_hacia_jugador = sign(body.global_position.x - global_position.x)
			if direccion_hacia_jugador == 0:
				direccion_hacia_jugador = 1.0 
				
			# Aquí llamamos a la función
			body.recibir_empujon(direccion_hacia_jugador, fuerza_empuje)
