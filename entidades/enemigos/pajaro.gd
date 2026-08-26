extends CharacterBody2D

# --- CONFIGURACIÓN ---
@export var speed: float = 120.0
@export var vida: int = 3
# Estas variables te dejarán arrastrar las escenas de la Piedra y la Llave desde tus archivos
@export var escena_piedra: PackedScene 
@export var escena_llave: PackedScene

var direccion: int = 1 # 1 es derecha, -1 es izquierda
var puede_recibir_daño: bool = true

func _physics_process(delta: float) -> void:
	# 1. Movimiento horizontal constante
	velocity.x = speed * direccion
	velocity.y = 0 # No cae, vuela recto
	
	move_and_slide()
	
	# 2. Rebotar si toca una pared (debes poner paredes invisibles en los bordes de tu nivel)
	if is_on_wall():
		direccion *= -1 # Invierte la dirección
		
		# Voltear el dibujo según a dónde vuela
		if direccion > 0:
			$Sprite2D.flip_h = false
		else:
			$Sprite2D.flip_h = true

# Conecta la señal 'timeout' de tu nodo Timer a esta función
func _on_drop_timer_timeout() -> void:
	# Comprobamos que hayas asignado la escena de la piedra en el inspector
	if escena_piedra:
		# "Instanciar" es la forma elegante de decir "Crear una copia"
		var nueva_piedra = escena_piedra.instantiate()
		
		# Añadimos la piedra al nivel (el padre del pájaro)
		get_parent().add_child(nueva_piedra)
		
		# Le decimos a la piedra que aparezca exactamente donde está el pájaro
		nueva_piedra.global_position = self.global_position

func recibir_daño() -> void:
	if not puede_recibir_daño:
		return 
		
	vida -= 1
	
	if vida <= 0:
		morir()
	else:
		# Efecto de daño
		puede_recibir_daño = false
		$Sprite2D.modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.5).timeout
		$Sprite2D.modulate = Color(1, 1, 1)
		puede_recibir_daño = true

func morir() -> void:
	# Antes de borrarse, el pájaro crea la llave
	if escena_llave:
		var nueva_llave = escena_llave.instantiate()
		get_parent().add_child(nueva_llave)
		# La llave aparece donde murió el pájaro
		nueva_llave.global_position = self.global_position
		
	# Finalmente, el pájaro se elimina
	queue_free()
