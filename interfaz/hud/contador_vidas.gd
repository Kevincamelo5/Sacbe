extends CanvasLayer

@onready var texto_vidas: Label = $TextoVidas 

func _ready() -> void:
	# Verificamos que el GameManager esté disponible
	var game_manager = get_node_or_null("%GameManager")
	if game_manager:
		# Conectamos la señal a nuestra función local
		game_manager.vida_actualizada.connect(_on_vida_actualizada)
		# Seteamos el valor inicial
		_on_vida_actualizada(game_manager.vida)

# Agregamos 'nueva_vida' como argumento para que la función reconozca el dato
func _on_vida_actualizada(nueva_vida: int) -> void:
	texto_vidas.text = str(nueva_vida)
