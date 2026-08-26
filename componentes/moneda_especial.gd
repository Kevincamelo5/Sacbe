extends Node2D

@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animatedSprite.play("gira")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Jugador" or body.is_in_group("jugador"):
		
		# 1. Efectos visuales y de sonido
		$AudioStreamPlayer.play()
		animatedSprite.hide()
		
		# Pequeño consejo: Para desactivar colisiones correctamente en Godot 4 
		# sin errores en la consola, usa set_deferred en el Area2D
		$Area2D.set_deferred("monitoring", false)
		
		# 2. Notificar al Nivel
		var nivel_actual = get_tree().current_scene
		# Verificamos si el nivel tiene la función (por seguridad)
		if nivel_actual.has_method("recolectar_moneda_especial"):
			nivel_actual.recolectar_moneda_especial()
		else:
			push_warning("Este nivel no soporta monedas especiales.")
			
		# 3. Esperar y eliminar
		await $AudioStreamPlayer.finished
		queue_free()
