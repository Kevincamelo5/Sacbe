extends Node

var moneda = 0
var vida = 5
var arma_equipada_actual: String = "cuchillo"
## Ruta de la escena/nivel en la que se encuentra el jugador (para poder reiniciarlo).
var nivel_actual: String = "res://niveles/nivel1/nivel1_parte1.tscn"

## Indica si hay una partida empezada que se pueda continuar.
var partida_guardada: bool = false
## Indica si el tutorial inicial ya se mostró en la partida actual.
var tutorial_visto: bool = false
## Escena que cargara el boton "Cargar partida".
var escena_guardada: String = ""
## Vida y monedas que se restauran al cargar la partida.
var vida_guardada: int = 5
var moneda_guardada: int = 0

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

## Armas que ya fueron mejoradas en la tienda (solo estas pueden dañar a Huay).
var armasMejoradas = {
	"cuchillo": false,
	"hacha": false,
	"lanza": false,
	"escudo": false,
	"flauta": false,
	"macuahuitle": false
}

## Equipa el cuchillo como arma inicial al empezar un nivel.
func equipar_arma_inicial() -> void:
	arma_equipada_actual = "cuchillo"
	arma_cambiada.emit()

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

## Reinicia las vidas del jugador al empezar un nuevo nivel.
## (Las monedas se conservan por ahora.)
func reiniciar_estado():
	vida = 5
	vida_actualizada.emit(vida)

func _inicio_del_nivel(ruta: String) -> String:
	for clave in INICIO_NIVELES:
		if ruta.contains(clave):
			return INICIO_NIVELES[clave]
	return "res://niveles/nivel1/nivel1_parte1.tscn"

## Guarda la partida para continuar exactamente donde esta el jugador (por ejemplo, al pausar).
func guardar_partida(ruta_escena: String = "") -> void:
	if ruta_escena == "":
		var escena_actual = get_tree().current_scene
		if escena_actual and escena_actual.scene_file_path != "":
			ruta_escena = escena_actual.scene_file_path
	if ruta_escena == "":
		return
	
	nivel_actual = ruta_escena
	escena_guardada = ruta_escena
	vida_guardada = vida
	moneda_guardada = moneda
	partida_guardada = true

## Guarda la partida para empezar de nuevo el nivel en el que murio el jugador.
func guardar_partida_en_inicio_nivel(ruta_escena: String = "") -> void:
	if ruta_escena == "":
		ruta_escena = nivel_actual
	if ruta_escena == "":
		return
	
	nivel_actual = ruta_escena
	escena_guardada = _inicio_del_nivel(ruta_escena)
	# Al reiniciar el nivel se recuperan las vidas y se pierden las monedas.
	vida_guardada = 5
	moneda_guardada = 0
	partida_guardada = true

## Carga la partida guardada. Devuelve false si no hay ninguna.
func cargar_partida() -> bool:
	if not partida_guardada or escena_guardada == "":
		return false
	
	vida = vida_guardada
	moneda = moneda_guardada
	vida_actualizada.emit(vida)
	puntuacion_actualizada.emit(moneda)
	
	get_tree().change_scene_to_file(escena_guardada)
	return true

## Prepara el estado para empezar una partida desde cero.
func nueva_partida() -> void:
	vida = 5
	moneda = 0
	nivel_actual = "res://niveles/nivel1/nivel1_parte1.tscn"
	partida_guardada = false
	escena_guardada = ""
	tutorial_visto = false
	vida_actualizada.emit(vida)
	puntuacion_actualizada.emit(moneda)

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
		# La partida guardada debe empezar desde el inicio del nivel donde murio
		guardar_partida_en_inicio_nivel(nivel_actual)
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
		print(nombreArma, " desbloqueada")
	else: print_debug("Error: El arma '", nombreArma, "' no existe en el diccionario.")

## Marca el arma indicada como mejorada. Devuelve true si se pudo mejorar.
func mejorar_arma(nombreArma: String) -> bool:
	if not armasMejoradas.has(nombreArma):
		print_debug("Error: El arma '", nombreArma, "' no existe en el diccionario.")
		return false
	if armasMejoradas[nombreArma]:
		return false
	
	armasMejoradas[nombreArma] = true
	print(nombreArma, " mejorada")
	return true

## Indica si el arma indicada ya fue mejorada.
func arma_esta_mejorada(nombreArma: String) -> bool:
	return armasMejoradas.get(nombreArma, false)
