extends CharacterBody2D
class_name Jugador

signal vida_cambiada(vidas_actuales)

@onready var sprite = $Sprite2D
@onready var anim = $Sprite2D/AnimationPlayer
var vida: int = 5

func _ready() -> void:
	if hayGravedad:
		velocity.y = 0
	call_deferred("emit_signal","vida_cambiada",vida)

func _physics_process(delta: float) -> void:
	_actualizar_temporizadores_salto(delta)
	_movimiento(delta)
	
	move_and_slide()
	
	_actualizar_temporizador_objeto(delta)
	_actualizar_estado_suelo()
	
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
	
	if direccion.x > 0:
		sprite.flip_h = false
	elif direccion.x < 0:
		sprite.flip_h = true
	
	velocity.x = direccion.x * _aceleracion

@export_category("salto")
@export var fuerzaSalto: float = -400.0
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
enum OBJETOS {CUCHILLO, LANZA, ESCUDO}
@export var objetoActual := OBJETOS.CUCHILLO
var _estaUsandoObjeto := false
var _temporizadorObjeto := 0.0

@export_category("ataque")
@export var dañoCuchillo:= 5
@export var enfriamientoCuchillo = 0.6
@export var dañoLanza:= 2.0
@export var enfriamientoLanza:= 0.35

func _usar_objeto() -> void:
	if not sprite.flip_h:
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
				escudar()
			_: print_debug("Objeto extraño")
	

func _actualizar_temporizador_objeto(delta: float):
	if _temporizadorObjeto > 0:
		_temporizadorObjeto -= delta
	
	if _estaUsandoObjeto and _temporizadorObjeto <= 0:
		_estaUsandoObjeto = false

# Ataques
@onready var areaCuchillo: Area2D = $AreaAtaque
var lanza: PackedScene = preload("res://entidad/Lanza/lanza.tscn")

# CUCHILLO
func acuchillar():
	print_debug("Acuchillando")
	var areas = areaCuchillo.get_overlapping_areas()
	
	if areas.size() > 0:
		for area in areas:
			if area is Hurtbox:
				area.lastimar(dañoCuchillo)

# LANZA
func lanzar():
	print_debug("Lanzando")
	var nuevaLanza: Lanza = lanza.instantiate()
	
	if sprite.flip_h:
		nuevaLanza.x = -1
	nuevaLanza.daño = dañoLanza
	get_parent().add_child(nuevaLanza)
	nuevaLanza.set_global_position(areaCuchillo.get_global_position() + Vector2(0, -20))

# ESCUDO
func escudar():
	print_debug("Escudando")

#ENTRADAS
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		
		if event.keycode == KEY_R:
			get_tree().reload_current_scene()
	
	if event.is_action_pressed("cambiar_objeto"):
		#get_tree().change_scene_to_file("res://interfaz/menu_objetos.tscn")
		objetoActual = wrap(objetoActual+1, 0, OBJETOS.size())
		print_debug("Arma cambiada a ", objetoActual)
		

#perder vidas
func _lose_lives() -> void:
	vida-=1
	vida_cambiada.emit(vida)
	print("Vidas restantes: ", vida)
	
	if vida <=0:
		get_tree().call_deferred("reload_current_scene")
