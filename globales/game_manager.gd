extends Node
var moneda = 0
var vida = 5

var armasDesbloqueadas = {
	"cuchillo": true,
	"hacha": false,
	"lanza": false,
	"escudo": false,
	"flauta":false,
	"macuahuitle": false 
}

signal puntuacion_actualizada(moneda_actual:int)
signal vida_actualizada(vida_actual:int)

func incrementar_monedas():
	moneda += 1
	puntuacion_actualizada.emit(moneda)
	print("Monedas recogidas: ", moneda)

func disminuir_vida(caida_al_vacio: bool = false):
	vida -= 1
	vida_actualizada.emit(vida)
	
	if vida <= 0:
		# Ir a pantalla de fin de juego
		get_tree().change_scene_to_file("res://interfaz/pantallas/muerto.tscn")
	elif caida_al_vacio:
		# Solo lo regresamos al inicio si la variable caida_al_vacio es true
		var jugador = get_tree().get_first_node_in_group("jugador") 
		if jugador and jugador.has_method("volver_al_inicio"):
			jugador.volver_al_inicio()

func aumentar_vida():
	vida += 1
	vida_actualizada.emit(vida)
	print("Vida aumentada: ", vida)

func comprar_vida(costo: int = 30) -> bool:
	if moneda >= costo: # Si monedas es 30 o más (mayor a 29)
		# 1. Ajustamos las variables
		moneda -= costo
		vida += 1
		
		# 2. Emitimos las señales para que el HUD en pantalla cambie de número
		vida_actualizada.emit(vida)
		
		# ADVERTENCIA: Usa el nombre exacto de la señal que ya usas en 
		# incrementar_monedas() para actualizar el HUD de monedas.
		# Asumiré que se llama "monedas_actualizadas" o "monedas_cambiadas".
		if has_signal("monedas_actualizadas"):
			emit_signal("monedas_actualizadas", moneda)
			
		print("¡Compra exitosa! Vidas: ", vida, " | Monedas restantes: ", moneda)
		return true
	else:
		print("Monedas insuficientes. Tienes ", moneda, " y necesitas ", costo)
		return false

func desbloquear_arma(nombreArma: String):
	if armasDesbloqueadas.has(nombreArma):
		armasDesbloqueadas[nombreArma] = true
		print(nombreArma, "desbloqueada")
	else: print_debug("Error: El arma '", nombreArma, "' no existe en el diccionario.")

# Añadir al final de game_manager.gd
func gastar_monedas(costo: int) -> bool:
	if moneda >= costo: # Usamos tu variable 'moneda' en singular
		moneda -= costo
		puntuacion_actualizada.emit(moneda) # Actualiza el HUD
		return true
	else:
		return false
