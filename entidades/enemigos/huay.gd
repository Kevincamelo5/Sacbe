extends CharacterBody2D

## Enemigo Huay: solo recibe daño si el arma equipada está mejorada.

@export var velocidad: float = 90.0
@export var gravedad: float = 1200.0
@export var vida_max: int = 6
@export var distancia_persecucion: float = 700.0
@export var distancia_ataque: float = 95.0

## Zona (en coordenadas del mundo) dentro de la cual Huay puede moverse.
## Si el ancho es 0, Huay se mueve sin límites.
@export var zona_final: Rect2 = Rect2()

## Tiempo de invulnerabilidad después de recibir un golpe. Mientras más corto,
## más fácil resulta conectar varios ataques seguidos.
const TIEMPO_INVULNERABILIDAD := 0.18

@onready var sprite = $AnimatedSprite2D
@onready var barra_vida: ProgressBar = $BarraVida
@onready var label_vida: Label = $BarraVida/Label
@onready var attack_timer: Timer = $TimerAtaque
@onready var area_ataque: Area2D = $AreaAtaque

var vida: int
var puede_recibir_daño := true
var puede_atacar := true
var jugador: Node2D
var _estilo_relleno: StyleBoxFlat

func _ready() -> void:
	vida = vida_max

	jugador = get_tree().get_first_node_in_group("jugador")
	if not jugador:
		jugador = get_parent().get_node_or_null("Jugador")
	attack_timer.timeout.connect(_on_timer_ataque_timeout)

	# Guardamos una copia del estilo para poder cambiar el color según la vida
	var estilo = barra_vida.get_theme_stylebox("fill")
	if estilo is StyleBoxFlat:
		_estilo_relleno = estilo.duplicate() as StyleBoxFlat
		barra_vida.add_theme_stylebox_override("fill", _estilo_relleno)

	_actualizar_barra()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravedad * delta

	if jugador and is_instance_valid(jugador):
		var diferencia := jugador.global_position - global_position
		var distancia := diferencia.length()

		# Si hay una zona final definida, Huay solo perseguirá hasta su borde,
		# de modo que no salga del área del altar.
		var objetivo_x := jugador.global_position.x
		if zona_final.size.x > 0.0:
			objetivo_x = clampf(objetivo_x, zona_final.position.x, zona_final.end.x)

		var diferencia_x := objetivo_x - global_position.x

		if distancia <= distancia_persecucion and abs(diferencia_x) > distancia_ataque:
			velocity.x = sign(diferencia_x) * velocidad
			if diferencia.x != 0:
				sprite.flip_h = diferencia.x < 0
		else:
			velocity.x = move_toward(velocity.x, 0, velocidad * 5 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad * 5 * delta)

	move_and_slide()

	# Nunca permite que Huay salga de la zona final.
	if zona_final.size.x > 0.0:
		global_position.x = clampf(global_position.x, zona_final.position.x, zona_final.end.x)

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
			sprite.play("Movimiento")
			break

func recibir_daño(cantidad: int = 1) -> void:
	if not GameManager.arma_esta_mejorada(GameManager.arma_equipada_actual):
		_avisar_arma_no_mejorada()
		return

	if not puede_recibir_daño:
		return

	vida -= cantidad
	_actualizar_barra()

	if vida <= 0:
		_morir()
		return

	puede_recibir_daño = false
	sprite.modulate = Color(1, 0.25, 0.25, 1)
	await get_tree().create_timer(TIEMPO_INVULNERABILIDAD).timeout
	if not is_inside_tree():
		return
	sprite.modulate = Color(1, 1, 1, 1)
	puede_recibir_daño = true

func _avisar_arma_no_mejorada() -> void:
	var nivel := get_tree().current_scene
	if nivel and nivel.has_method("mostrar_mensaje"):
		nivel.mostrar_mensaje("¡Solo un arma mejorada puede dañar a Huay!")

func _actualizar_barra() -> void:
	if not is_instance_valid(barra_vida):
		return

	var vida_actual = max(vida, 0)
	barra_vida.max_value = vida_max
	barra_vida.value = vida_actual

	if label_vida:
		label_vida.text = "%d/%d" % [vida_actual, vida_max]

	if _estilo_relleno:
		var porcentaje := 0.0
		if vida_max > 0:
			porcentaje = float(vida_actual) / float(vida_max)

		var color := Color(0.30, 0.80, 0.30) # Verde
		if porcentaje <= 0.30:
			color = Color(0.85, 0.15, 0.10) # Rojo
		elif porcentaje <= 0.60:
			color = Color(0.90, 0.70, 0.15) # Amarillo
		_estilo_relleno.bg_color = color

func _morir() -> void:
	puede_recibir_daño = false
	puede_atacar = false
	set_physics_process(false)
	area_ataque.set_deferred("monitoring", false)
	$Cuerpo.set_deferred("monitoring", false)
	barra_vida.hide()

	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.6)
	await tween.finished

	var nivel := get_tree().current_scene
	if nivel and nivel.has_method("mostrar_mensaje"):
		nivel.mostrar_mensaje("¡Huay ha sido derrotado!")

	queue_free()
