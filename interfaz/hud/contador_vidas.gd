extends CanvasLayer

# Crea un arreglo con las rutas exactas a tus nuevos nodos TextureRect.
@onready var iconos_corazones = [
	$Corazones/Corazon1,
	$Corazones/Corazon2,
	$Corazones/Corazon3,
	$Corazones/Corazon4,
	$Corazones/Corazon5
]

func _ready() -> void:
	# 1. Intentamos obtener el GameManager desde la raíz (Autoload)
	var gm = get_node_or_null("/root/GameManager")
	
	if gm:
		# 2. Conectamos la señal para futuros cambios
		if not gm.vida_actualizada.is_connected(_on_vida_actualizada):
			gm.vida_actualizada.connect(_on_vida_actualizada)
		
		# 3. Actualizamos la interfaz inmediatamente al cargar la escena
		_on_vida_actualizada(gm.vida)

func _on_vida_actualizada(nueva_vida: int) -> void:
	# Recorremos la lista de corazones de izquierda a derecha
	for i in range(iconos_corazones.size()):
		if i < nueva_vida:
			# Si el índice es menor a la vida actual, el corazón se muestra
			iconos_corazones[i].show()
		else:
			# Si el índice es mayor o igual
			iconos_corazones[i].hide()
