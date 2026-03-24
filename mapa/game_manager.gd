extends Node
var moneda = 0
var vida = 5

signal puntuacion_actualizada(moneda_actual:int)
signal vida_actualizada(vida_actual:int)

func incrementar_monedas():
	moneda += 1
	puntuacion_actualizada.emit(moneda)
	print("Monedas recogidas: ", moneda)

func disminuir_vida():
	vida -= 1
	vida_actualizada.emit(vida)
	print("Daño recibido: ", vida)

func aumentar_vida():
	vida += 1
	vida_actualizada.emit(vida)
	print("Vida aumentada: ", vida)
