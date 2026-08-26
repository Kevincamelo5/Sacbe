extends CharacterBody2D

# --- VARIABLES EXPORTABLES ---
@export var patrol_speed: float = 100.0
@export var chase_speed: float = 160.0
@export var patrol_range: float = 300.0
@export var vision_range: float = 400.0
@export var flip_h_original: bool = true
@export var is_vertical: bool = false # NUEVO: Activar en Inspector para patrullaje Y

# --- REFERENCIAS ---
@onready var sprite = $AnimatedSprite2D
@onready var start_pos_x: float = global_position.x
@onready var start_pos_y: float = global_position.y # NUEVO: Posición Y original

# --- ESTADOS ---
enum State { PATROL, CHASE }
var current_state = State.PATROL

# Variables de control
var direction: float = -1.0
var player: Node2D = null

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	# Gravedad: Excluimos a los enemigos verticales/voladores
	if not is_on_floor() and not is_vertical:
		velocity.y += 980 * delta
		
	vigilar_entorno()
	
	match current_state:
		State.PATROL:
			patrol_logic()
		State.CHASE:
			chase_logic()
			
	move_and_slide()

# --- LÓGICA DE VISIÓN (MATEMÁTICA) ---
func vigilar_entorno():
	if player:
		var distance_to_player = abs(global_position.x - player.global_position.x)
		var distance_y = abs(global_position.y - player.global_position.y)
		
		if distance_to_player <= vision_range and distance_y < 100:
			current_state = State.CHASE
		else:
			current_state = State.PATROL

# --- LÓGICA DE PATRULLAJE ---
func patrol_logic():
	if not is_vertical:
		# Patrulla Horizontal
		var right_bound = start_pos_x + (patrol_range / 2.0)
		var left_bound = start_pos_x - (patrol_range / 2.0)
		
		if global_position.x >= right_bound:
			direction = -1.0
		elif global_position.x <= left_bound:
			direction = 1.0
			
		velocity.x = direction * patrol_speed
		velocity.y = 0 
		update_sprite_direction(direction)
	else:
		# Patrulla Vertical
		var bottom_bound = start_pos_y + (patrol_range / 2.0)
		var top_bound = start_pos_y - (patrol_range / 2.0)
		
		if global_position.y >= bottom_bound:
			direction = -1.0 # Sube
		elif global_position.y <= top_bound:
			direction = 1.0 # Baja
			
		velocity.y = direction * patrol_speed
		velocity.x = 0 

# --- LÓGICA DE PERSECUCIÓN ---
func chase_logic():
	if player:
		var dir_to_player = sign(player.global_position.x - global_position.x)
		direction = dir_to_player
		
		if abs(global_position.x - player.global_position.x) > 10:
			velocity.x = direction * chase_speed
			if is_vertical: 
				velocity.y = 0 # Fija el eje Y al perseguir
			update_sprite_direction(direction)
		else:
			velocity.x = 0

# --- ACTUALIZAR SPRITE ---
func update_sprite_direction(dir: float):
	if dir > 0:
		sprite.flip_h = not flip_h_original
	elif dir < 0:
		sprite.flip_h = flip_h_original
