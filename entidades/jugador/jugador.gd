extends CharacterBody2D
class_name Jugador

signal vida_cambiada(vidas_actuales)
var spawn_position : Vector2
var _estaProtegido := false
var _recibiendo_dano := false
var _tiempo_invulnerable := 0.0
var _escala_sprite_base := Vector2.ONE

@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
func _ready() -> void:
	add_to_group("jugador")
	spawn_position = global_position
	_escala_sprite_base = animatedSprite.scale
	
	if hayGravedad:
		velocity.y = 0
	call_deferred("emit_signal","vida_cambiada")
	
	if GameManager:
		match GameManager.arma_equipada_actual:
			"cuchillo":
				objetoActual = OBJETOS.CUCHILLO
			"lanza":
				objetoActual = OBJETOS.LANZA
			"escudo":
				objetoActual = OBJETOS.ESCUDO
			"hacha":
				objetoActual = OBJETOS.HACHA
			"flauta":
				objetoActual = OBJETOS.FLAUTA
			"macuahuitle":
				objetoActual = OBJETOS.MACUAHUITLE

	# Animación del macuahuitl (arma final del Nivel 5)
	var tex_macuahuitl := preload("res://activos/arte/(512) Quitzal macuahuitle v2 frentre.png")
	if not animatedSprite.sprite_frames.has_animation("macuahuitle"):
		animatedSprite.sprite_frames.add_animation("macuahuitle")
		animatedSprite.sprite_frames.add_frame("macuahuitle", tex_macuahuitl, 1.0)
		animatedSprite.sprite_frames.set_animation_loop("macuahuitle", false)
	animatedSprite.sprite_frames.set_animation_speed("macuahuitle", 6.0)

	

func volver_al_inicio() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO #Detenemos cualquier movimiento previo

func _physics_process(delta: float) -> void:
	_actualizar_temporizadores_salto(delta)
	_movimiento(delta)
	
	move_and_slide()
	
	_actualizar_temporizador_objeto(delta)
	_actualizar_estado_suelo()
	_actualizar_invulnerabilidad(delta)
	
	if Input.is_action_pressed("usar_objeto") and hayGravedad:
		_usar_objeto()

# MOVIMIENTO
@export_category("movimiento")
@export var hayGravedad: bool = true

@export var velocidad: float = 500
var direccion := Vector2.ZERO
var _aceleracion := 0.0

func _movimiento(delta: float) -> void:
	if direccion != Vector2.ZERO:
		_aceleracion += velocidad * 2 * delta
	else:
		_aceleracion -= velocidad * 5 * delta
	
	_aceleracion = clamp(_aceleracion, 0, velocidad)
	
	_movimiento_horizontal()
	_movimiento_vertical(delta)

func _movimiento_horizontal() -> void:
	direccion.x = Input.get_axis("izquierda", "derecha")
	
	# 1. Primero controlamos hacia dónde mira el personaje (flip_h)
	if direccion.x > 0:
		animatedSprite.flip_h = false
	elif direccion.x < 0:
		animatedSprite.flip_h = true
	
	# 2. Luego controlamos las animaciones basándonos en si está en el suelo o no
	if not _estaUsandoObjeto and not _recibiendo_dano:
		if not is_on_floor():
			_reproducir("saltar")
		elif direccion.x != 0:
			_reproducir("correr")
		else:
			_reproducir("parado")
	# 3. Aplicamos la velocidad
	velocity.x = direccion.x * _aceleracion

## Reproduce una animación ajustando la escala para que todas las poses
## del personaje se vean del mismo tamaño.
func _reproducir(anim: String) -> void:
	animatedSprite.play(anim)
	animatedSprite.scale = _escala_sprite_base * _factor_escala(anim)

## Devuelve el factor de escala según la animación. La animación "parado"
## está dibujada más grande en su imagen original, así que la reducimos
## para que coincida con "correr" y las animaciones de ataque.
func _factor_escala(anim: String) -> float:
	if anim == "parado":
		return 0.88
	return 1.0

@export_category("salto")
@export var fuerzaSalto: float = -500.0
@export var gravedad: float = 980
## Aceleración de la caída
@export var multCaida: float = 1.5 
## Permite posponer un salto antes de tocar el suelo
@export var tiempoBufferSalto: float = 0.25 
## Permite saltar un poco después de salir de una plataforma
@export var tiempoCoyoteTime: float = 0.3 
var _bufferSaltoTemporizador: float = 0.0
var _coyoteTimeTemporizador: float = 0.0
var _estaEnSuelo: bool = false

func _movimiento_vertical(delta: float) -> void:
	if not hayGravedad:
		direccion.y = Input.get_axis("saltar", "agacharse")
		
		velocity.y = direccion.y * _aceleracion
	else:
		if Input.is_action_just_pressed("saltar"):
			_bufferSaltoTemporizador = tiempoBufferSalto
		
		var gravedadActual = gravedad
		
		# Gravedad aumentada en caída y en pico del salto
		if velocity.y > 0 or (velocity.y < 0 and not Input.is_action_pressed("saltar")):
			gravedadActual *= multCaida
		
		if not is_on_floor() and Input.is_action_pressed("agacharse"):
			velocity.y = -fuerzaSalto
		
		velocity.y += gravedadActual * delta
		
		if _puede_saltar():
			# Saltar
			velocity.y = fuerzaSalto
			_bufferSaltoTemporizador = 0.0
			_coyoteTimeTemporizador = 0.0

func _puede_saltar():
	return (_bufferSaltoTemporizador > 0 and _coyoteTimeTemporizador > 0) or \
		   (_bufferSaltoTemporizador > 0 and is_on_floor())

func _actualizar_temporizadores_salto(delta: float) -> void:
	if _bufferSaltoTemporizador > 0:
		_bufferSaltoTemporizador -= delta
	
	if _estaEnSuelo and is_on_floor():
		_coyoteTimeTemporizador = tiempoCoyoteTime
	elif _coyoteTimeTemporizador > 0:
		_coyoteTimeTemporizador -= delta

func _actualizar_estado_suelo() -> void:
	_estaEnSuelo = is_on_floor()

# OBJETOS
@export_category("objeto")
enum OBJETOS {CUCHILLO, LANZA, ESCUDO, HACHA, FLAUTA, MACUAHUITLE}
@export var objetoActual := OBJETOS.CUCHILLO
var _estaUsandoObjeto := false
var _temporizadorObjeto := 0.0

@export_category("ataque")
@export var dañoCuchillo:= 5
@export var enfriamientoCuchillo = 0.6
@export var dañoLanza:= 2.0
@export var enfriamientoLanza:= 0.35
@export var dañoHacha = 1
@export var enfriamientoHacha = 1.5
@export var dañoMacuahuitle = 7
@export var enfriamientoMacuahuitle = 0.85
@export var tiempoEscudo = 1.5

func _usar_objeto() -> void:
	if not animatedSprite.flip_h:
		areaCuchillo.position.x = 77
	else:
		areaCuchillo.position.x = -77
	
	if not _estaUsandoObjeto:
		_estaUsandoObjeto = true
		match objetoActual:
			OBJETOS.CUCHILLO:
				_temporizadorObjeto = enfriamientoCuchillo
				acuchillar()
			OBJETOS.LANZA:
				_temporizadorObjeto = enfriamientoLanza
				lanzar()
			OBJETOS.ESCUDO:
				_temporizadorObjeto = tiempoEscudo
				escudar()
			OBJETOS.HACHA:
				_temporizadorObjeto = enfriamientoHacha
				atacar_hacha()
			OBJETOS.MACUAHUITLE:
				_temporizadorObjeto = enfriamientoMacuahuitle
				atacar_macuahuitl()
			OBJETOS.FLAUTA:
				_temporizadorObjeto = 1.0 # O la variable de enfriamiento que le asignes
				tocar_flauta()
			_: print_debug("Objeto extraño")
	

func _actualizar_temporizador_objeto(delta: float):
	if _temporizadorObjeto > 0:
		_temporizadorObjeto -= delta
	
	if _estaUsandoObjeto and _temporizadorObjeto <= 0:
		_estaUsandoObjeto = false
		_estaProtegido = false

# Ataques
@onready var areaCuchillo: Area2D = $AreaAtaque
var lanza: PackedScene = preload("res://objetos/Lanza/lanza.tscn")

# CUCHILLO
# En Jugador.gd (por ejemplo, en acuchillar() o atacar_hacha()):

func acuchillar():
	print_debug("Acuchillando")
	# Reproducimos la animación antes de aplicar el daño. Si el golpe activa
	# el daño del jugador (por ejemplo, una puerta con respuesta incorrecta),
	# la animación de recibir daño no debe ser sobrescrita por la de ataque.
	_reproducir("acuchillar")

	var areas = areaCuchillo.get_overlapping_areas()
	
	for area in areas:
		if area.has_method("lastimar"):
			area.lastimar(dañoCuchillo)
		elif area.has_method("recibir_dano"):
			area.recibir_dano(dañoCuchillo)

# LANZA
func lanzar():
	print_debug("Lanzando")
	var nuevaLanza: Lanza = lanza.instantiate()
	
	if animatedSprite.flip_h:
		nuevaLanza.x = -1
	nuevaLanza.daño = dañoLanza
	get_parent().add_child(nuevaLanza)
	nuevaLanza.set_global_position(areaCuchillo.get_global_position() + Vector2(0, -20))
	
	# Agrega esta línea para que se vea la animación
	_reproducir("Ataque Lanza")

# ESCUDO
func escudar():
	print_debug("Escudando")
	_estaProtegido = false
	_reproducir("escudarse")

	# La protección empieza justo cuando la animación muestra el escudo
	# cubriendo por completo al jugador (último frame).
	var ultimo_frame := animatedSprite.sprite_frames.get_frame_count("escudarse") - 1
	while animatedSprite.animation == "escudarse" and animatedSprite.frame < ultimo_frame:
		await animatedSprite.frame_changed

	if animatedSprite.animation != "escudarse":
		# La animación se interrumpió (por ejemplo, al recibir daño):
		# liberamos el uso del objeto para que no se quede bloqueado.
		_temporizadorObjeto = 0.0
		return

	_estaProtegido = true
	# Mantener la protección durante todo el tiempo configurado
	# a partir del momento en que el escudo ya está completo.
	_temporizadorObjeto = tiempoEscudo

# HACHA
func atacar_hacha():
	print("--- INTENTO DE ATAQUE CON HACHA ---")
	
	# 1. Reproducimos la animación
	_reproducir("Ataque Hacha")
	
	# 2. Le damos tiempo a Godot de mover el área invisible a los 77 píxeles
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# 3. Revisamos qué tocamos
	var areas = areaCuchillo.get_overlapping_areas()
	print("Número de cosas que tocó mi arma: ", areas.size())
	
	if areas.size() > 0:
		for area in areas:
			if area is Hurtbox:
				area.lastimar(dañoHacha)

# MACUAHUITLE
func atacar_macuahuitl():
	print_debug("Atacando con Macuahuitl")
	_reproducir("macuahuitle")

	var areas = areaCuchillo.get_overlapping_areas()
	for area in areas:
		if area.has_method("lastimar"):
			area.lastimar(dañoMacuahuitle)
		elif area.has_method("recibir_dano"):
			area.recibir_dano(dañoMacuahuitle)

# FLAUTA
func tocar_flauta():
	print_debug("Tocando la Flauta")
	_reproducir("Toca Flauta")
	

#ENTRADAS
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		
		if event.keycode == KEY_R:
			get_tree().reload_current_scene()
	
	if event.is_action_pressed("cambiar_objeto"):
		_cambiar_siguiente_objeto_desbloqueado()
		
func _cambiar_siguiente_objeto_desbloqueado():
	var total_objetos = OBJETOS.size()
	var nombreArmas = ["cuchillo", "lanza", "escudo", "hacha", "flauta", "macuahuitle"]
	
	for i in range(total_objetos):
		#Avanza uno de los objetos a la vez en el ciclo del enum
		objetoActual = wrap(objetoActual + 1, 0, total_objetos)
	
		#verificamos si la nueva esta desbloqueada en el GameManager
		var nombre_arma_actual = nombreArmas[objetoActual]
		if GameManager.armasDesbloqueadas.get(nombre_arma_actual, false):
			print_debug("Arma cambiada a ", nombre_arma_actual)
			# Sincronizar el arma en el GameManager y avisar a la interfaz
			GameManager.arma_equipada_actual = nombre_arma_actual
			if GameManager.has_signal("arma_cambiada"):
				GameManager.arma_cambiada.emit()
			break 
	
# perder vidas
@onready var Audio_dano = $AudioDano

## Alias público para que otros nodos (puertas, enemigos, trampas...) le
## quiten vida al jugador usando el mismo flujo de daño.
func recibir_dano(cantidad: int = 1) -> void:
	_lose_lives()

func _lose_lives() -> void:
	if not _estaProtegido and not _recibiendo_dano:
		_recibiendo_dano = true
		_tiempo_invulnerable = 0.6
		Audio_dano.play()
		_reproducir("recibirDaño")
		# Forzamos el reinicio: si "recibirDaño" ya era la animación actual
		# (por ejemplo, tras un golpe anterior) Godot no la reinicia sola.
		animatedSprite.set_frame_and_progress(0, 0.0)
		
		# Reducimos la vida de inmediato, sin depender de la animación
		GameManager.disminuir_vida(false)
	else:
		print("Ataque bloqueado")

## Desactiva la invulnerabilidad cuando termina la pequeña ventana de protección.
func _actualizar_invulnerabilidad(delta: float) -> void:
	if _recibiendo_dano:
		_tiempo_invulnerable -= delta
		if _tiempo_invulnerable <= 0.0:
			_recibiendo_dano = false
		
func recibir_empujon(direccion: float, fuerza: float):
	# Aplica la fuerza horizontal (hacia la izquierda o derecha)
	velocity.x = direccion * fuerza
	
	# Aplica una fuerza vertical para que el jugador "salte" al quemarse
	# Recuerda que en Godot, el eje Y negativo es hacia arriba
	velocity.y = -600.0	
