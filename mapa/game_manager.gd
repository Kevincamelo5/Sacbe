extends Node
var moneda = 0

@onready var contador_monedas: Label = $contador_monedas

signal puntuacion_actualizada(moneda_actual:int)

func incrementar_monedas():
	moneda += 1
	puntuacion_actualizada.emit(moneda)
	contador_monedas.text = str(moneda)
