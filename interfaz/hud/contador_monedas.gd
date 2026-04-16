extends CanvasLayer

@onready var contador_monedas: Label = $contador_monedas
	
func _ready() -> void:
	var game_manager = get_node_or_null("/root/GameManager")
	game_manager.puntuacion_actualizada.connect(_on_puntuacion_actualizada)
	
func _on_puntuacion_actualizada(puntuacion_actual: int)->void:
	contador_monedas.text = str(puntuacion_actual)
	
	
