extends CharacterBody2D
class_name Lanza

@export var x = 1
@export var velocidad = 1000
@export var daño = 0

func _ready() -> void:
	velocity.x = x * velocidad

func _physics_process(delta: float) -> void:
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		area.lastimar(daño)
		queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is StaticBody2D:
		velocity = Vector2.ZERO
		await get_tree().create_timer(2).timeout
		queue_free()
