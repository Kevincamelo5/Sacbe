extends CharacterBody2D

@onready var player_node: CharacterBody2D = get_parent().get_node("Jugador")
var speed: float = 65.0
var vida: int = 3
var should_chase: bool = false

func _physics_process(delta: float) -> void:
	if should_chase:
		var direction = (player_node.global_position-global_position).normalized()
		velocity = lerp(velocity, direction * speed, 8.5*delta)
		move_and_slide()
		if direction.x > 0:
			$Sprite2D.flip_h = false
		if direction.x < 0:
			$Sprite2D.flip_h = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player_node:
		get_tree().call_deferred("reload_current_scene")
	if body.get_collision_layer_value(3):
		recibir_daño()


func _on_enter_area_body_entered(body: Node2D) -> void:
	if body == player_node:
		pass # Replace with function body.


func _on_exit_area_body_entered(body: Node2D) -> void:
	if body == player_node:
		pass # Replace with function body.

func recibir_daño() -> void:
	vida -= 1
	if vida <= 0:
		queue_free()
	pass
