extends CharacterBody2D

## Enemigo Huay: solo recibe daño si el arma equipada está mejorada.

@export var velocidad: float = 90.0
@export var gravedad: float = 1200.0
@export var vida_max: int = 10
@export var distancia_persecucion: float = 700.0
@export var distancia_ataque: float = 95.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var label_vida: Label = $LabelVida
@onready var attack_timer: Timer = $TimerAtaque
@onready var area_ataque: Area2D = $AreaAtaque

var vida: int
var puede_recibir_daño := true
var puede_atacar := true
var jugador: Node2D

func _ready() -> void:
	vida = vida_max

	jugador = get_tree().get_first_node_in_group("jugador")
	if not jugador:
		jugador = get_parent().get_node_or_null("Jugador")
	attack_timer.timeout.connect(_on_timer_ataque_timeout)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravedad * delta

	if jugador and is_instance_valid(jugador):
		var diferencia := jugador.global_position - global_position
		var distancia := diferencia.length()

		if distancia <= distancia_persecucion and abs(diferencia.x) > distancia_ataque:
			velocity.x = sign(diferencia.x) * velocidad
			if diferencia.x != 0:
				sprite.flip_h = diferencia.x < 0
		else:
			velocity.x = move_toward(velocity.x, 0, velocidad * 5 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad * 5 * delta)

	move_and_slide()

func _on_area_ataque_body_entered(body: Node2D) -> void:
	if body == jugador and puede_atacar:
		puede_atacar = false
		if body.has_method("_lose_lives"):
			body._lose_lives()
		attack_timer.start()

func _on_timer_ataque_timeout() -> void:
	puede_atacar = true

	# Si el jugador sigue dentro del área, vuelve a atacar.
	for body in area_ataque.get_overlapping_bodies():
		if body == jugador:
			_on_area_ataque_body_entered(body)
			break

func recibir_daño(cantidad: int = 1) -> void:
	if not GameManager.arma_esta_mejorada(GameManager.arma_equipada_actual):
		_avisar_arma_no_mejorada()
		return

	if not puede_recibir_daño:
		return

	vida -= cantidad
	

	if vida <= 0:
		_morir()
		return

	puede_recibir_daño = false
	sprite.modulate = Color(1, 0.25, 0.25, 1)
	await get_tree().create_timer(0.35).timeout
	sprite.modulate = Color(1, 1, 1, 1)
	puede_recibir_daño = true

func _avisar_arma_no_mejorada() -> void:
	var nivel := get_tree().current_scene
	if nivel and nivel.has_method("mostrar_mensaje"):
		nivel.mostrar_mensaje("¡Solo un arma mejorada puede dañar a Huay!")


func _morir() -> void:
	puede_recibir_daño = false
	puede_atacar = false
	set_physics_process(false)
	area_ataque.set_deferred("monitoring", false)
	$Cuerpo.set_deferred("monitoring", false)
	label_vida.hide()

	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.6)
	await tween.finished

	var nivel := get_tree().current_scene
	if nivel and nivel.has_method("mostrar_mensaje"):
		nivel.mostrar_mensaje("¡Huay ha sido derrotado!")

	queue_free()
