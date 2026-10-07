extends Hurtbox
class_name PlayerHurtbox

@export var salud_maxima: int = 30
@export var inmunidad: float = 0.5

var salud_actual: int
var _es_inmune: bool = false

func _ready() -> void:
	salud_actual = salud_maxima

func lastimar(cantidad: float = 1.0) -> void:
	if _es_inmune:
		return
	
	salud_actual -= int(cantidad)
	_activar_inmunidad()
	
	if salud_actual <= 0:
		get_parent().queue_free()

func _activar_inmunidad() -> void:
	_es_inmune = true
	await get_tree().create_timer(inmunidad).timeout
	_es_inmune = false
