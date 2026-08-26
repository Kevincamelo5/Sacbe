extends Area2D

# --- SEÑAL: Para detectar al jugador ---
# Ve a la pestaña "Nodos" del Area2D, busca la señal "body_entered" y conéctala:
func _on_body_entered(body: Node2D) -> void:
	# Verificamos si quien tocó la llave es exactamente el jugador
	if body.name == "Jugador":
		
		# Opcional: Le avisamos al script del jugador que ya tiene la llave.
		# (Para que esto funcione, el script de tu Jugador debe tener una función llamada 'recoger_llave')
		if body.has_method("recoger_llave"):
			body.recoger_llave()
			
		# Aquí también podrías poner código para reproducir un sonido de "¡Ding!"
		
		# Nos deshacemos de la llave en la pantalla
		queue_free()
