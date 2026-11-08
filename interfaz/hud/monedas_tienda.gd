extends PanelContainer

@onready var _cantidad: Label = $HBox/Label


func _ready() -> void:
	_actualizar(GameManager.moneda)

	if not GameManager.puntuacion_actualizada.is_connected(_actualizar):
		GameManager.puntuacion_actualizada.connect(_actualizar)


func _actualizar(cantidad: int) -> void:
	_cantidad.text = str(cantidad)
