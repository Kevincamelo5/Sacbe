extends CharacterBody2D

# --- CONFIGURACIÓN ---
@export var speed: float = 160.0
@export var vida: int = 20

# Parámetros para el movimiento de subida y bajada (onda)
@export var amplitud_onda: float = 50.0  # Distancia máxima vertical
@export var frecuencia_onda: float = 3.0 # Velocidad de oscilación

# Escenas
@export var escena_piedra: PackedScene 
@export var escena_llave: PackedScene

var direccion: int = 1 # 1 es derecha, -1 es izquierda
var puede_recibir_daño: bool = true
var tiempo: float = 0.0

var vida_max: int = 0
var _estilo_relleno: StyleBoxFlat

@onready var barra_vida: ProgressBar = $BarraVida
@onready var label_vida: Label = $BarraVida/Label

func _ready() -> void:
	vida_max = vida
	barra_vida.max_value = vida_max
	
	# Guardamos una copia del estilo para poder cambiar el color según la vida
	var estilo = barra_vida.get_theme_stylebox("fill")
	if estilo is StyleBoxFlat:
		_estilo_relleno = estilo.duplicate() as StyleBoxFlat
		barra_vida.add_theme_stylebox_override("fill", _estilo_relleno)
	
	# El pajaro puede atravesar al jugador, pero choca con paredes y pisos
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		add_collision_exception_with(jugador)
	
	_actualizar_barra()

func _physics_process(delta: float) -> void:
	# Acumular el tiempo transcurrido
	tiempo += delta
	
	# 1. Movimiento horizontal constante y oscilación vertical
	velocity.x = speed * direccion
	velocity.y = sin(tiempo * frecuencia_onda) * amplitud_onda
	
	move_and_slide()
	
	# 2. Rebotar si toca una pared
	if is_on_wall():
		var normal_pared = get_wall_normal()
		if normal_pared.x != 0.0:
			direccion = int(sign(normal_pared.x))
			$AnimatedSprite2D.flip_h = direccion < 0

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
	_actualizar_barra()
	
	if vida <= 0:
		morir()
	else:
		puede_recibir_daño = false
		$AnimatedSprite2D.modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.5).timeout
		$AnimatedSprite2D.modulate = Color(1, 1, 1)
		puede_recibir_daño = true

func morir() -> void:
	if escena_llave:
		var nueva_llave = escena_llave.instantiate()
		get_parent().add_child(nueva_llave)
		nueva_llave.global_position = self.global_position
		
	queue_free()

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
