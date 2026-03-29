extends Area2D
class_name Hurtbox

@export var fnLastimar: Callable
@export var fnMorir: Callable

@export_category("Estadísticas")
@export var saludMaxima: int = 30
@export var inmunidad:= 0.5

var saludActual: int
var _esInmune := false
var _inmunidadTemporizador:= 0.0


func _ready() -> void:
	saludActual = saludMaxima
	if not fnLastimar: push_warning("Sin efecto de Lastimar")
	if not fnMorir: push_warning("Usando Morir por defecto")

func _physics_process(delta: float) -> void:
	if _esInmune:
		_inmunidadTemporizador -= delta
		if _inmunidadTemporizador <= 0:
			_esInmune = false
			# Resetear efecto

func lastimar(cantidad: int) -> void:
	if _esInmune:
		return
	
	saludActual -= cantidad
	print_debug(name, " recibió ", cantidad, " de daño. Vida: ", saludActual)
	
	# Efectos de daño
	_activar_inmunidad()
	
	if saludActual <= 0:
		if fnMorir: fnMorir.call()
		else: get_parent().queue_free()
		
		print_debug("Muerto")

func _activar_inmunidad() -> void:
	_esInmune = true
	_inmunidadTemporizador = inmunidad
	
	if fnLastimar: fnLastimar.call()
