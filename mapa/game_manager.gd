extends Node
var moneda = 0

signal puntuacion_actualizada(moneda_actual:int)

func incrementar_monedas():
	moneda += 1
	puntuacion_actualizada.emit(moneda)
	print("Monedas recogidas: ", moneda)
