extends CharacterBody2D
# Variables del Jefe
var vida: int = 5
var velocidad_embestida: float = 400.0
var gravedad: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# Estados posibles del jabalí
enum Estado { ESPERANDO, PREPARANDO, EMBISTIENDO }
var estado_actual = Estado.ESPERANDO
var direccion = -1 # -1 es izquierda, 1 es derecha
var jugador: Node2D = null
var _ataque_cd: float = 0.0

@onready var timer = $Timer
@onready var sprite = $AnimatedSprite2D
@onready var iconos_corazones = [
	$Corazones/Sprite2D,
	$Corazones/Sprite2D2,
	$Corazones/Sprite2D3,
	$Corazones/Sprite2D4,
	$Corazones/Sprite2D5
]

func _ready() -> void:
	# Conectamos el Timer por código para el tiempo de recarga
	timer.timeout.connect(_on_timer_timeout)
	timer.wait_time = 2.0 # El jabalí ataca cada 2 segundos
	timer.start()
	actualizar_direccion_sprite()

func _physics_process(delta: float) -> void:
	# 1. Aplicar gravedad para que toque el suelo
	if not is_on_floor():
		velocity.y += gravedad * delta

	_ataque_cd = max(_ataque_cd - delta, 0.0)
	if jugador == null:
		jugador = get_tree().get_first_node_in_group("jugador")

	# 2. Comportamiento según el estado
	match estado_actual:
		Estado.ESPERANDO:
			velocity.x = 0
			# Aquí podrías poner: sprite.frame = (cuadro de respirar)
			
		Estado.PREPARANDO:
			velocity.x = 0
			# Aquí podrías poner: sprite.frame = (cuadro de rascar el piso)
			
		Estado.EMBISTIENDO:
			# Se mueve hacia la dirección actual
			velocity.x = direccion * velocidad_embestida
			
			# ¡Aquí reproducimos tu animación!
			sprite.play("Embestida")
			
			# Detectar si chocó contra el muro invisible de tu arena
			if is_on_wall():
				chocar_contra_muro()

	# Ejecutar el movimiento
	move_and_slide()
	_comprobar_contacto()

## Daña al jugador cuando el jabalí lo toca durante la embestida.
func _comprobar_contacto() -> void:
	if jugador == null or _ataque_cd > 0:
		return
	if global_position.distance_to(jugador.global_position) < 75.0:
		_ataque_cd = 1.0
		if jugador.has_method("_lose_lives"):
			jugador._lose_lives()
		elif jugador.has_method("recibir_dano"):
			jugador.recibir_dano(1)

# Función que se activa cuando el Timer llega a 0
func _on_timer_timeout() -> void:
	if estado_actual == Estado.ESPERANDO:
		preparar_ataque()

func preparar_ataque() -> void:
	estado_actual = Estado.PREPARANDO
	
	# Le damos al jugador medio segundo de advertencia antes de arrancar
	await get_tree().create_timer(0.3).timeout 
	
	estado_actual = Estado.EMBISTIENDO

func chocar_contra_muro() -> void:
	# Cuando choca, se detiene y vuelve a esperar
	estado_actual = Estado.ESPERANDO
	
	# Invertimos la dirección matemática (de -1 a 1, o de 1 a -1)
	direccion *= -1 
	
	# Llamamos a nuestra función para voltear el dibujo correctamente
	actualizar_direccion_sprite()
		
	# Reiniciamos el timer de recarga
	timer.start()

# Esta función la llamarás desde el arma de tu jugador o si saltas sobre él
func recibir_dano(_cantidad: int) -> void:
	# Cada golpe quita exactamente 1 de vida, sin importar el arma.
	vida -= 1
	
	# Prevenimos que la vida baje de 0 para evitar errores visuales
	if vida < 0:
		vida = 0
		
	actualizar_interfaz_corazones()
	
	sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1, 1, 1)
	
	if vida <= 0:
		morir()
		
func actualizar_interfaz_corazones() -> void:
	# Recorre los 5 corazones. Si el índice es menor a la vida, se muestra. Si es mayor o igual, se oculta.
	for i in range(iconos_corazones.size()):
		if i < vida:
			iconos_corazones[i].show()
		else:
			iconos_corazones[i].hide()



func actualizar_direccion_sprite() -> void:
	# Como tu dibujo original mira a la DERECHA:
	if direccion == -1: # Si se mueve a la izquierda
		sprite.flip_h = true
	elif direccion == 1: # Si se mueve a la derecha
		sprite.flip_h = false

func morir() -> void:
	print("¡Jefe derrotado!")
	get_tree().change_scene_to_file("res://niveles/nivel2/escena_historia.tscn")
	queue_free()
