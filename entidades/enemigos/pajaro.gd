extends CharacterBody2D

# --- CONFIGURACIÓN ---
@export var speed: float = 120.0
@export var vida: int = 3

# Parámetros para el movimiento de subida y bajada (onda)
@export var amplitud_onda: float = 50.0  # Distancia máxima vertical
@export var frecuencia_onda: float = 3.0 # Velocidad de oscilación

# Escenas
@export var escena_piedra: PackedScene 
@export var escena_llave: PackedScene

var direccion: int = 1 # 1 es derecha, -1 es izquierda
var puede_recibir_daño: bool = true
var tiempo: float = 0.0

func _physics_process(delta: float) -> void:
	# Acumular el tiempo transcurrido
	tiempo += delta
	
	# 1. Movimiento horizontal constante y oscilación vertical
	velocity.x = speed * direccion
	velocity.y = sin(tiempo * frecuencia_onda) * amplitud_onda
	
	move_and_slide()
	
	# 2. Rebotar si toca una pared
	if is_on_wall():
		direccion *= -1 # Invierte la dirección
		
		# Voltear el dibujo según a dónde vuela
		if direccion > 0:
			$Sprite2D.flip_h = false
		else:
			$Sprite2D.flip_h = true

# Conecta la señal 'timeout' de tu nodo Timer a esta función
func _on_drop_timer_timeout() -> void:
	if escena_piedra:
		var nueva_piedra = escena_piedra.instantiate()
		get_parent().add_child(nueva_piedra)
		nueva_piedra.global_position = self.global_position

func recibir_daño(cantidad: int = 1) -> void:
	if not puede_recibir_daño:
		return 
		
	vida -= cantidad 
	
	if vida <= 0:
		morir()
	else:
		puede_recibir_daño = false
		$Sprite2D.modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.5).timeout
		$Sprite2D.modulate = Color(1, 1, 1)
		puede_recibir_daño = true

func morir() -> void:
	if escena_llave:
		var nueva_llave = escena_llave.instantiate()
		get_parent().add_child(nueva_llave)
		nueva_llave.global_position = self.global_position
		
	queue_free()
