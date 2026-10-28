extends CharacterBody2D
## Kakasbal: jefe final del Nivel 5 (Templo Mayor).
## Tres fases: Ave -> Jaguar -> Humano. Cada fase tiene su propio sprite y
## comportamiento. Recibe 1 punto de vida por golpe (3 golpes por fase).

signal jefe_derrotado

enum Fase { AVE, JAGUAR, HUMANO }
enum Estado { IDLE, ATAQUE, RECUPERAR }

@export var vida_por_fase: int = 5
@export var velocidad_ave: float = 200.0
@export var velocidad_jaguar: float = 360.0
@export var velocidad_humano: float = 300.0
@export var y_vuelo: float = 150.0  # Altura a la que vuela el ave (más baja para poder golpearla)

var fase_actual: Fase = Fase.AVE
var estado_actual: Estado = Estado.IDLE
var vida: int
var direccion: int = -1
var gravedad: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var puede_recibir_dano: bool = true
var _tiempo: float = 0.0
var _tiempo_ataque: float = 0.0
var _ataque_cd: float = 0.0
var _objetivo: Vector2 = Vector2.ZERO

var jugador: Node2D = null

const CORAZON := preload("res://componentes/escenarios/Corazon.png")

@onready var sprite_ave: AnimatedSprite2D = $Sprites/AVE
@onready var sprite_jaguar: AnimatedSprite2D = $Sprites/JAGUAR
@onready var sprite_humano: Sprite2D = $Sprites/Humano
@onready var attack_timer: Timer = $AttackTimer

var corazones: Array = []

func _ready() -> void:
	add_to_group("enemigos")
	_configurar_fase_inicial()
	vida = vida_por_fase
	_crear_corazones()
	_actualizar_sprites()
	_actualizar_corazones()
	attack_timer.wait_time = 1.8
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_iniciar_ataque)
	attack_timer.start()

## Determina en qué forma aparece Kakasbal según el flujo del Nivel 5.
## El GameManager guarda la fase ("ave", "jaguar" o "humano") antes de
## cargar la arena de combate.
func _configurar_fase_inicial() -> void:
	if GameManager:
		match str(GameManager.get("fase_kakasbal")):
			"jaguar":
				fase_actual = Fase.JAGUAR
			"humano":
				fase_actual = Fase.HUMANO
			_:
				fase_actual = Fase.AVE

func _physics_process(delta: float) -> void:
	_tiempo += delta
	if _ataque_cd > 0:
		_ataque_cd -= delta
	if jugador == null:
		jugador = get_tree().get_first_node_in_group("jugador")

	match fase_actual:
		Fase.AVE:
			_fase_ave(delta)
		Fase.JAGUAR:
			_fase_jaguar(delta)
		Fase.HUMANO:
			_fase_humano(delta)

	# La gravedad sólo aplica en las fases terrestres
	if fase_actual != Fase.AVE and not is_on_floor():
		velocity.y += gravedad * delta

	move_and_slide()
	_comprobar_contacto()

# ---------------------------------------------------------------- FASES
func _fase_ave(delta: float) -> void:
	match estado_actual:
		Estado.IDLE:
			velocity.x = direccion * velocidad_ave
			var dy = y_vuelo - global_position.y
			velocity.y = sin(_tiempo * 3.0) * 40.0 + clamp(dy * 3.0, -200.0, 200.0)
			if is_on_wall():
				direccion *= -1
				_voltear()
		Estado.ATAQUE:
			if jugador:
				_objetivo = jugador.global_position
			var dir = (_objetivo - global_position).normalized()
			velocity = dir * velocidad_ave * 1.5
			_tiempo_ataque += delta
			# Se mantiene cerca del jugador el tiempo suficiente para poder golpearlo
			if _tiempo_ataque > 1.2 and global_position.distance_to(_objetivo) < 60.0:
				estado_actual = Estado.RECUPERAR
				_tiempo_ataque = 0.0
			elif _tiempo_ataque > 2.2:
				estado_actual = Estado.RECUPERAR
				_tiempo_ataque = 0.0
		Estado.RECUPERAR:
			var target = Vector2(global_position.x, y_vuelo)
			var dir = (target - global_position).normalized()
			velocity = dir * velocidad_ave * 0.7
			if abs(global_position.y - y_vuelo) < 15.0:
				estado_actual = Estado.IDLE
				attack_timer.start()

func _fase_jaguar(delta: float) -> void:
	if not is_on_floor():
		velocity.x = 0
		return
	match estado_actual:
		Estado.IDLE:
			velocity.x = 0
			_mirar_jugador()
		Estado.ATAQUE:
			velocity.x = direccion * velocidad_jaguar
			if is_on_wall():
				estado_actual = Estado.RECUPERAR
				_tiempo_ataque = 0.0
		Estado.RECUPERAR:
			velocity.x = 0
			_tiempo_ataque += delta
			if _tiempo_ataque > 0.6:
				estado_actual = Estado.IDLE
				attack_timer.start()

func _fase_humano(delta: float) -> void:
	if not is_on_floor():
		velocity.x = 0
		return
	match estado_actual:
		Estado.IDLE:
			if jugador:
				direccion = 1 if jugador.global_position.x >= global_position.x else -1
			velocity.x = direccion * velocidad_humano * 0.5
			_voltear()
			if is_on_wall():
				direccion *= -1
		Estado.ATAQUE:
			velocity.x = direccion * velocidad_humano * 1.8
			_tiempo_ataque += delta
			if is_on_wall() or _tiempo_ataque > 0.5:
				estado_actual = Estado.RECUPERAR
				_tiempo_ataque = 0.0
		Estado.RECUPERAR:
			velocity.x = 0
			_tiempo_ataque += delta
			if _tiempo_ataque > 0.5:
				estado_actual = Estado.IDLE
				attack_timer.start()

# ---------------------------------------------------------------- ATAQUE
func _iniciar_ataque() -> void:
	if fase_actual == Fase.JAGUAR:
		_mirar_jugador()
	estado_actual = Estado.ATAQUE
	_tiempo_ataque = 0.0

func _mirar_jugador() -> void:
	if jugador:
		direccion = 1 if jugador.global_position.x >= global_position.x else -1
	_voltear()

func _comprobar_contacto() -> void:
	if jugador == null or _ataque_cd > 0:
		return
	if global_position.distance_to(jugador.global_position) < 90.0:
		_ataque_cd = 1.2
		if jugador.has_method("_lose_lives"):
			jugador._lose_lives()
		elif jugador.has_method("recibir_dano"):
			jugador.recibir_dano(1)

# ---------------------------------------------------------------- DAÑO
func recibir_dano(cantidad = 1) -> void:
	if not puede_recibir_dano:
		return
	puede_recibir_dano = false
	vida -= 1
	_actualizar_corazones()

	var s = _sprite_activo()
	if s:
		s.modulate = Color(1, 0.3, 0.3)

	if vida <= 0:
		_cambiar_fase()
		return

	await get_tree().create_timer(0.2).timeout
	if is_instance_valid(s):
		s.modulate = Color(1, 1, 1)
	puede_recibir_dano = true

func _cambiar_fase() -> void:
	# En el Nivel 5 cada arena muestra una sola forma de Kakasbal
	# (ave, jaguar o humano). Al agotar su vida, el jefe es derrotado
	# y la arena decide a qué escena avanzar (la siguiente operación).
	_dar_recompensa()
	_morir()

## Entrega monedas al jugador al vencer cada forma de Kakasbal.
func _dar_recompensa() -> void:
	if not GameManager:
		return
	match fase_actual:
		Fase.AVE:
			GameManager.sumar_monedas(25)
		Fase.JAGUAR:
			GameManager.sumar_monedas(30)
		Fase.HUMANO:
			GameManager.sumar_monedas(35)

func _morir() -> void:
	set_physics_process(false)
	jefe_derrotado.emit()
	queue_free()

# ---------------------------------------------------------------- VISUAL
func _sprite_activo():
	match fase_actual:
		Fase.AVE:
			return sprite_ave
		Fase.JAGUAR:
			return sprite_jaguar
		Fase.HUMANO:
			return sprite_humano
	return null

func _actualizar_sprites() -> void:
	sprite_ave.visible = (fase_actual == Fase.AVE)
	sprite_jaguar.visible = (fase_actual == Fase.JAGUAR)
	sprite_humano.visible = (fase_actual == Fase.HUMANO)
	if fase_actual == Fase.AVE:
		sprite_ave.play("default")
	elif fase_actual == Fase.JAGUAR:
		sprite_jaguar.play("Jaguar correr")

func _voltear() -> void:
	var s = _sprite_activo()
	if s:
		s.flip_h = (direccion < 0)

func _crear_corazones() -> void:
	var cont := Node2D.new()
	cont.name = "Corazones"
	add_child(cont)
	for i in range(vida_por_fase):
		var s := Sprite2D.new()
		s.texture = CORAZON
		s.scale = Vector2(0.12, 0.12)
		s.position = Vector2(-100.0 + i * 50.0, -140.0)
		cont.add_child(s)
		corazones.append(s)

func _actualizar_corazones() -> void:
	for i in range(corazones.size()):
		corazones[i].visible = (i < vida)
