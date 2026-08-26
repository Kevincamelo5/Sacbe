extends Area2D

@export var velocidad_caida: float = 300.0
@export var fuerza_empuje: float = 1200.0

func _process(delta):
	# Hace que la piedra caiga constantemente
	global_position.y += velocidad_caida * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("recibir_empujon"):
			var direccion = sign(body.global_position.x - global_position.x)
			if direccion == 0:
				direccion = 1.0 
			body.recibir_empujon(direccion, fuerza_empuje)
			
		# La piedra se destruye al golpear al jugador
		queue_free()
	elif body is TileMap or body.is_in_group("suelo"):
		# Se destruye si choca con el piso (ajusta según tu juego)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	# Se destruye si sale de la vista de la cámara
	queue_free()


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	pass # Replace with function body.
