extends Node2D

@onready var game_manager = get_tree().current_scene.find_child("GameManager")
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

func _ready() -> void:
	animatedSprite.play("gira")

func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Jugador or body.name == "Jugador" or body.is_in_group("jugador"):
		# 1. Deshabilitar la colisión de inmediato usando set_deferred
		collision_shape.set_deferred("disabled", true)
		
		# 2. Ocultar el sprite de la moneda
		animatedSprite.hide()
		
		# 3. Dar la moneda y reproducir el sonido
		GameManager.incrementar_monedas()
		$AudioStreamPlayer.play()
		
		# 4. Esperar a que termine el audio y eliminar el nodo
		await $AudioStreamPlayer.finished
		queue_free()
