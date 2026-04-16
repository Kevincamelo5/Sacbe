extends Area2D

@export var velocidad_caida := 400.0
@onready var posicion_inicial := global_position
@onready var timer := $TimerCaida

var cayendo := false

func _ready() -> void:
	# Configuramos el timer para un tiempo aleatorio de inicio
	_reiniciar_estalactita()
	# Conectamos la señal de colisión
	body_entered.connect(_on_body_entered)
	timer.timeout.connect(_iniciar_caida)

func _process(delta: float) -> void:
	if cayendo:
		position.y += velocidad_caida * delta

func _iniciar_caida() -> void:
	cayendo = true

func _reiniciar_estalactita() -> void:
	cayendo = false
	global_position = posicion_inicial
	# Tiempo aleatorio entre 1 y 5 segundos para volver a caer
	timer.wait_time = randf_range(1.0, 5.0)
	timer.start()

func _on_body_entered(body: Node2D) -> void:
	if body.get_collision_layer_value(2):
		# Lógica de daño
		GameManager.disminuir_vida()
		
	elif body.get_collision_layer_value(1):
		# Si toca el piso, desaparece y vuelve arriba
		_reiniciar_estalactita()
	elif body.is_in_group("vacio"):
		_reiniciar_estalactita()
		
