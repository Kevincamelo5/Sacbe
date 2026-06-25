extends CharacterBody2D

@onready var player_node: CharacterBody2D = get_parent().get_node("Jugador")
@onready var attack_timer: Timer = $attacktimer

var speed: float = 100.0
var vida: int = 3
var aceleracion: float = 7.0
var should_chase: bool = false
var can_attack: bool = true

var puede_recibir_daño: bool = true

func _physics_process(delta: float) -> void:
	#el enemigo se mueve solo si should_chase = true
	if should_chase and player_node:
		var direction = (player_node.global_position - global_position).normalized()
		velocity = velocity.lerp(direction * speed, 10.0 * delta)
		move_and_slide()
		
		#orientacion del Sprite
		if direction.x > 0:
			$Sprite2D.flip_h = false
		elif direction.x < 0:
			$Sprite2D.flip_h = true
	
	else:
		#frena suavemente sin dejar de perseguir
		velocity = velocity.lerp(Vector2.ZERO, 5.0 * delta)
		move_and_slide()
			
#Deteccion para Empezar a perseguir
func _on_enter_area_body_entered(body: Node2D) -> void:
	if body == player_node:
		should_chase = true
		$AnimatedSprite2D.hide()

#deteccion para detener la persecucion (opcional, si quieres que se rinda)
func _on_exit_area_body_exited(body: Node2D) -> void:
	if body == player_node:
		should_chase = false

#Deteccion de contacto para atacar
func _on_atack_area_body_entered(body: Node2D) -> void:
	if body == player_node and can_attack:
		atacar_jugador(body)

func atacar_jugador(player: Node2D) -> void:
	if player.has_method("_lose_lives"):
		player._lose_lives()
		$AudioStreamPlayer.play()
		#Logica de esperar un segundo
		can_attack = false
		attack_timer.start() #Inicia temporizador de 1 segundo

#Se activa cuando el AttackTimer termina
func _on_attacktimer_timeout() -> void:
	can_attack = true
	#si el jugador sigue en el area de ataque al terminar el segundo,
	#volver a atacar mediante la señal body_entered o verificar overlapping_bodies.
	
func recibir_daño() -> void:
	# 1. Si no puede recibir daño en este momento, ignoramos la función
	if not puede_recibir_daño:
		return 
		
	# 2. Restamos la vida
	vida -= 1
	
	var direccion_retroceso = 1
	if player_node:
		direccion_retroceso = sign(global_position.x - player_node.global_position.x)
		
		if direccion_retroceso == 0:
			direccion_retroceso = 1
	
	var tween = create_tween()
	tween.tween_property(self,"global_position:x",global_position.x + ( 50 * direccion_retroceso), 0.2)
	
	# 3. Comprobamos si muere
	if vida <= 0:
		queue_free()
	else:
		# 4. Si sobrevive, lo hacemos invulnerable temporalmente
		puede_recibir_daño = false
		
		# (Opcional) Cambiamos el color a rojo para indicar daño
		$Sprite2D.modulate = Color(1, 0, 0) # Rojo
		
		# 5. Esperamos medio segundo (0.5). Puedes ajustar este tiempo.
		await get_tree().create_timer(1).timeout
		
		# 6. Le devolvemos su color normal y le permitimos recibir daño de nuevo
		$Sprite2D.modulate = Color(1, 1, 1) # Blanco (Normal)
		puede_recibir_daño = true

#func _on_cuerpo_area_entered(area: Area2D) -> void:
#	if get_collision_layer_value(3):
#		recibir_daño()
