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
	
	if vida <= 0:
		# Ir a pantalla de fin de juego o construcción
		get_tree().change_scene_to_file("res://interfaz/pantallas/enConstrucci[on.tscn")
	else:
		# Buscamos al jugador en la escena actual para moverlo
		var jugador = get_tree().get_first_node_in_group("jugador") 
		if jugador and jugador.has_method("volver_al_inicio"):
			jugador.volver_al_inicio()

func aumentar_vida():
	vida += 1
	vida_actualizada.emit(vida)
	print("Vida aumentada: ", vida)
