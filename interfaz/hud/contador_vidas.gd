extends CanvasLayer

# Asegúrate de arrastrar tu nodo Label aquí desde la jerarquía, o usar el nombre correcto
@onready var texto_vidas: Label = $TextoVidas 

func _ready() -> void:
	# 1. Buscamos al jugador en la escena actual
	var jugador = get_tree().get_first_node_in_group("Jugador")
	
	# 2. Si lo encontramos, nos conectamos a su señal
	if jugador:
		# Conectamos la señal "vida_cambiada" a nuestra función "actualizar_texto"
		jugador.vida_cambiada.connect(actualizar_texto)
		
		# Ponemos el texto inicial (ej: "5")
		actualizar_texto(jugador.vida)

# Esta función se llama automáticamente cada vez que el jugador pierde vida
func actualizar_texto(nueva_vida: int) -> void:
	texto_vidas.text = str(nueva_vida)
