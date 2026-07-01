extends CanvasLayer

# Asegúrate de que el nombre del nodo $contador_monedas coincide con tu escena
@onready var contador_monedas: Label = $contador_monedas
	
func _ready() -> void:
	# 1. Conectamos la señal directamente al Autoload global
	GameManager.puntuacion_actualizada.connect(_on_puntuacion_actualizada)
	
	# 2. Obligamos al texto a mostrar las monedas actuales inmediatamente al entrar al nivel
	contador_monedas.text = str(GameManager.moneda)

func _on_puntuacion_actualizada(puntuacion: int) -> void:
	contador_monedas.text = str(puntuacion)
