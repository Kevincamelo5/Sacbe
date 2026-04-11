extends CanvasLayer

# Asegúrate de arrastrar tu nodo Label aquí desde la jerarquía, o usar el nombre correcto
@onready var texto_vidas: Label = $TextoVidas 

func _ready() -> void:
	var game_manager = get_node("%GameManager")
	game_manager.vida_actualizada.connect(_on_vida_actualizada)

func  _on_vida_actualizada() -> void:
	texto_vidas.text = str(nueva_vida)
