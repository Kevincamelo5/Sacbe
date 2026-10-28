extends Node

var moneda = 0
var vida = 5
var arma_equipada_actual: String = "cuchillo"
## Ruta de la escena/nivel en la que se encuentra el jugador (para poder reiniciarlo).
var nivel_actual: String = "res://niveles/nivel1/nivel1_parte1.tscn"

signal arma_cambiada
signal puntuacion_actualizada(moneda_actual: int)
signal vida_actualizada(vida_actual: int)

## Fase de Kakasbal a la que se enfrentará el jugador en el Nivel 5.
## Valores válidos: "ave", "jaguar", "humano".
var fase_kakasbal: String = "ave"
## Escena a la que se avanza tras derrotar la fase actual de Kakasbal.
var siguiente_tras_fase: String = ""

var armasDesbloqueadas = {
	"cuchillo": true,
	"hacha": false,
	"lanza": false,
	"escudo": false,
	"flauta": false,
	"macuahuitle": false 
}

## Escena inicial de cada nivel, usada para reiniciar desde el principio del nivel.
const INICIO_NIVELES := {
	"nivel1/": "res://niveles/nivel1/nivel1_parte1.tscn",
	"nivel2/": "res://niveles/nivel2/nivel2_parte1.tscn",
	"nivel3/": "res://niveles/nivel3/nivel3_parte1.tscn",
	"nivel4/": "res://niveles/nivel4/nivel4_parte_1.tscn",
	"nivel5/": "res://niveles/nivel5/nivel5_reto_suma.tscn",
}

# --- FUNCIÓN MODIFICADA ---
func reiniciar_nivel():
	# 1. Restablecer vidas y emitir señal para la interfaz
	vida = 5
	vida_actualizada.emit(vida)
	
	# 2. Restablecer monedas y emitir señal para la interfaz
	moneda = 0
	puntuacion_actualizada.emit(moneda)
	
	# 3. Cambiar de escena al inicio del nivel correspondiente
	get_tree().change_scene_to_file(_inicio_del_nivel(nivel_actual))

func _inicio_del_nivel(ruta: String) -> String:
	for clave in INICIO_NIVELES:
		if ruta.contains(clave):
			return INICIO_NIVELES[clave]
	return "res://niveles/nivel1/nivel1_parte1.tscn"

func incrementar_monedas():
	moneda += 1
	puntuacion_actualizada.emit(moneda)
	print("Monedas: ", moneda)

## Suma una cantidad de monedas (usada como recompensa al vencer a Kakasbal).
func sumar_monedas(cantidad: int):
	moneda += cantidad
	puntuacion_actualizada.emit(moneda)
	print("Monedas: ", moneda)

func gastar_monedas(costo: int) -> bool:
	if moneda >= costo:
		moneda -= costo
		puntuacion_actualizada.emit(moneda) # Actualiza el HUD
		return true
	else:
		return false

func disminuir_vida(caida_al_vacio: bool = false):
	vida -= 1
	vida_actualizada.emit(vida)
	
	if vida <= 0:
		# Guardamos la escena actual para poder reiniciarla desde la pantalla de muerte
		var escena_actual = get_tree().current_scene
		if escena_actual and escena_actual.scene_file_path != "":
			nivel_actual = escena_actual.scene_file_path
		# Ir a pantalla de fin de juego
		get_tree().change_scene_to_file("res://interfaz/pantallas/muerto.tscn")
	elif caida_al_vacio:
		var jugador = get_tree().get_first_node_in_group("jugador") 
		if jugador and jugador.has_method("volver_al_inicio"):
			jugador.volver_al_inicio()

func aumentar_vida():
	vida += 1
	vida_actualizada.emit(vida)
	print("Vida: ", vida)

func comprar_vida(costo: int = 30) -> bool:
	if moneda >= costo: # Si monedas es 30 o más (mayor a 29)
		# 1. Ajustamos las variables
		moneda -= costo
		vida += 1
		
		# 2. Emitimos las señales para que el HUD en pantalla cambie de número
		vida_actualizada.emit(vida)
		
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
