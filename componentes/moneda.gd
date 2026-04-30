extends Node2D

@onready var game_manager = get_tree().current_scene.find_child("GameManager")
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animatedSprite.play("gira")

func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_area_2d_body_entered(body: Node2D) -> void:
	
	if body is Jugador or body.name == "Jugador" or body.is_in_group("jugador"):
		$AudioStreamPlayer.play() 	   	
		animatedSprite.hide()
		$Area2D/CollisionShape2D.hide()
		GameManager.incrementar_monedas()
		await $AudioStreamPlayer.finished
		queue_free()
