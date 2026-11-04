extends CharacterBody2D

const ALPHA_ESTATICO: float = 0.5
const ALPHA_VISIBLE: float = 1.0
const DURACION_DESVANECIDO: float = 0.6

@onready var player_node: CharacterBody2D = get_parent().get_node("Jugador")
@onready var attack_timer: Timer = $attacktimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var speed: float = 100.0
var vida: int = 3
var aceleracion: float = 7.0
var should_chase: bool = false
var can_attack: bool = true

var puede_recibir_daño: bool = true

func _ready() -> void:
	# Estado estatico: el anima se ve semitransparente
	modulate = Color(1, 1, 1, ALPHA_ESTATICO)
	animated_sprite.animation = &"anima estocada"
	animated_sprite.frame = 0
	animated_sprite.stop()

func _physics_process(delta: float) -> void:
	# El enemigo se mueve solo si should_chase = true
	if should_chase and player_node:
		var direction = (player_node.global_position - global_position).normalized()
		velocity = velocity.lerp(direction * speed, 10.0 * delta)
		move_and_slide()
		
		# Orientacion del Sprite
		if direction.x > 0:
			animated_sprite.flip_h = false
		elif direction.x < 0:
			animated_sprite.flip_h = true
	else:
		# Frena suavemente sin dejar de perseguir
		velocity = velocity.lerp(Vector2.ZERO, 5.0 * delta)
		move_and_slide()

# Deteccion para Empezar a perseguir
func _on_enter_area_body_entered(body: Node2D) -> void:
	if body == player_node:
		should_chase = true
		# Al perseguir se materializa por completo
		modulate = Color(1, 1, 1, ALPHA_VISIBLE)

# Deteccion para detener la persecucion
func _on_exit_area_body_exited(body: Node2D) -> void:
	if body == player_node:
		should_chase = false
		# Vuelve a su estado estatico semitransparente
		modulate = Color(1, 1, 1, ALPHA_ESTATICO)

# Deteccion de contacto para atacar
func _on_atack_area_body_entered(body: Node2D) -> void:
	if body == player_node and can_attack:
		atacar_jugador(body)

func atacar_jugador(player: Node2D) -> void:
	modulate = Color(1, 1, 1, ALPHA_VISIBLE)
	$AudioStreamPlayer.play()
	animated_sprite.play("anima estocada")
	# El daño se aplica justo cuando termina la estocada
	await animated_sprite.animation_finished
	if player.has_method("_lose_lives"):
		player._lose_lives()
	
	# Vuelve a la pose estatica
	animated_sprite.stop()
	animated_sprite.frame = 0
	
	can_attack = false
	attack_timer.start()
	
	# Si el jugador ya no esta cerca, vuelve a estar semitransparente
	if not should_chase:
		modulate = Color(1, 1, 1, ALPHA_ESTATICO)

func _on_attacktimer_timeout() -> void:
	can_attack = true

# CAMBIO AQUÍ: Añadimos (cantidad: int = 1) para aceptar el daño que le envía la Hurtbox
func recibir_daño(cantidad: int = 1) -> void:
	# 1. Si no puede recibir daño en este momento, ignoramos la función
	if not puede_recibir_daño:
		return 
		
	# 2. Restamos la cantidad de vida recibida
	vida -= cantidad
	
	var direccion_retroceso = 1
	if player_node:
		direccion_retroceso = sign(global_position.x - player_node.global_position.x)
		if direccion_retroceso == 0:
			direccion_retroceso = 1
	
	var tween = create_tween()
	tween.tween_property(self, "global_position:x", global_position.x + (50 * direccion_retroceso), 0.2)
	
	# 3. Comprobamos si muere
	if vida <= 0:
		morir()
	else:
		# 4. Si sobrevive, lo hacemos invulnerable temporalmente
		puede_recibir_daño = false
		
		# Cambiamos el color a rojo para indicar daño (conservando la opacidad)
		var alpha_actual := modulate.a
		modulate = Color(1, 0, 0, alpha_actual)
		
		# 5. Esperamos 1 segundo
		await get_tree().create_timer(1.0).timeout
		
		# 6. Devolvemos su color normal y le permitimos recibir daño de nuevo
		modulate = Color(1, 1, 1, alpha_actual)
		puede_recibir_daño = true

func morir() -> void:
	puede_recibir_daño = false
	can_attack = false
	should_chase = false
	
	# Pierde opacidad hasta desaparecer
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, DURACION_DESVANECIDO)
	await tween.finished
	queue_free()
