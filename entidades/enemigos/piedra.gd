extends Area2D

@export var velocidad_caida: float = 250.0

func _physics_process(delta: float) -> void:
	# La piedra simplemente se mueve hacia abajo (eje Y positivo en Godot)
	position.y += velocidad_caida * delta

func _on_body_entered(body: Node2D) -> void:
	# 1. Usamos el grupo en lugar del nombre exacto
	if body.is_in_group("jugador"):
		if body.has_method("_lose_lives"):
			body._lose_lives()
		queue_free()
		  
	# 2. Si golpea el suelo
	elif body is TileMap or body is StaticBody2D:
		queue_free()

# --- SEÑAL 2: Para limpiar la memoria ---
# Selecciona el nodo VisibleOnScreenNotifier2D, busca la señal "screen_exited" y conéctala:
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free() # Si la piedra sale de la vista de la cámara, se borra
