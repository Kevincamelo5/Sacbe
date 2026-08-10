extends CharacterBody2D

# --- VARIABLES EXPORTABLES ---
@export var patrol_speed: float = 100.0
@export var chase_speed: float = 160.0
@export var patrol_range: float = 300  # Rango de patrulla (izq a der)
@export var vision_range: float = 400.0  # A qué distancia (en píxeles) te ve
@export var flip_h_original: bool = true

# --- REFERENCIAS ---
@onready var sprite = $AnimatedSprite2D
@onready var start_pos_x: float = global_position.x

# --- ESTADOS ---
enum State { PATROL, CHASE }
var current_state = State.PATROL

# Variables de control
var direction: float = -1.0
var player: Node2D = null

func _ready():
	# Buscamos al jugador al iniciar la escena usando el grupo "player"
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	# Gravedad
	if not is_on_floor():
		velocity.y += 980 * delta
		
	# 1. Vigilar matemáticamente dónde está el jugador (Reemplaza al Area2D)
	vigilar_entorno()
	
	# 2. Máquina de Estados
	match current_state:
		State.PATROL:
			patrol_logic()
		State.CHASE:
			chase_logic()
			
	move_and_slide()

# --- LÓGICA DE VISIÓN (MATEMÁTICA) ---
func vigilar_entorno():
	if player:
		# Calculamos la distancia absoluta en X entre el enemigo y el jugador
		var distance_to_player = abs(global_position.x - player.global_position.x)
		var distance_y = abs(global_position.y - player.global_position.y)
		
		# Si está lo suficientemente cerca en X, y no está muy arriba/abajo en Y
		if distance_to_player <= vision_range and distance_y < 100:
			current_state = State.CHASE
		else:
			current_state = State.PATROL

# --- LÓGICA DE PATRULLAJE ORIGINAL ---
func patrol_logic():
	# Usamos tu lógica original con start_pos_x
	var right_bound = start_pos_x + (patrol_range / 2.0)
	var left_bound = start_pos_x - (patrol_range / 2.0)
	
	if global_position.x >= right_bound:
		direction = -1.0
	elif global_position.x <= left_bound:
		direction = 1.0
		
	velocity.x = direction * patrol_speed
	update_sprite_direction(direction)

# --- LÓGICA DE PERSECUCIÓN ---
func chase_logic():
	if player:
		# Extrae la dirección matemática (-1 o 1) hacia el jugador
		var dir_to_player = sign(player.global_position.x - global_position.x)
		direction = dir_to_player
		
		# Evita temblores si está justo encima del jugador
		if abs(global_position.x - player.global_position.x) > 10:
			velocity.x = direction * chase_speed
			update_sprite_direction(direction)
		else:
			velocity.x = 0

# --- ACTUALIZAR SPRITE ---
func update_sprite_direction(dir: float):
	if dir > 0:
		sprite.flip_h = not flip_h_original
	elif dir < 0:
		sprite.flip_h = flip_h_original
