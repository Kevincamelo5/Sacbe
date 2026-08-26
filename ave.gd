extends CharacterBody2D

# --- VARIABLES ---
@export var velocidad_vuelo: float = 120.0
@export var rango_patrulla: float = 250.0
@export var piedra_scene: PackedScene # Aquí arrastraremos la escena de la Piedra

@onready var timer_ataque = $TimerAtaque
@onready var sprite = $AnimatedSprite2D
@onready var punto_disparo = $PuntoDisparo
@onready var pos_inicial_x: float = global_position.x

var direccion: float = 1.0

func _physics_process(delta):
	patrullar()
	move_and_slide()

func patrullar():
	var limite_der = pos_inicial_x + (rango_patrulla / 2.0)
	var limite_izq = pos_inicial_x - (rango_patrulla / 2.0)
	
	if global_position.x >= limite_der:
		direccion = -1.0
	elif global_position.x <= limite_izq:
		direccion = 1.0
		
	velocity.x = direccion * velocidad_vuelo
	velocity.y = 0 # Mantiene el vuelo horizontal estable
	
	# Actualizar sprite
	if direccion > 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

# Esta función se llama cada vez que el Timer llega a 0
func _on_timer_ataque_timeout():
	
	
	if piedra_scene:
		
		var nueva_piedra = piedra_scene.instantiate()
		nueva_piedra.global_position = punto_disparo.global_position
		
		# NOTA: Usar get_parent() suele ser más seguro que current_scene
		get_parent().add_child(nueva_piedra) 



func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	# Cuando el ave entra en la pantalla, arranca el reloj
	timer_ataque.start()
	

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Cuando el ave sale de la pantalla, detiene el reloj para ahorrar memoria
	timer_ataque.stop()
	
