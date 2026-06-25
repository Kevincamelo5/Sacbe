extends CanvasLayer

var costoH = 0
var costoE = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	$noteAlcanza.hide()
	mostrar()

func mostrar():
	var tree = get_tree()
	if tree:
		visible = true
		tree.paused = true
	else:
		print("Error: El SceneTree no está disponible todavía.")

func equipar_arma_al_jugador(id_arma: int):
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		jugador.objetoActual = id_arma

func mostrar_error_dinero():
	$noteAlcanza.show()
	$Timer.start(3.0)
	await $Timer.timeout
	$noteAlcanza.hide()

func cerrar_menu():
	visible = false
	get_tree().paused = false


# --- BOTÓN HACHA ---
func _on_hacha_pressed() -> void:
	# 1. Verificamos si YA la tiene desbloqueada
	if GameManager.armasDesbloqueadas.get("hacha", false) == true:
		equipar_arma_al_jugador(3)
		cerrar_menu()
	else:
		# 2. Si no la tiene, intentamos comprarla
		if GameManager.gastar_monedas(35):
			GameManager.desbloquear_arma("hacha")
			equipar_arma_al_jugador(3)
			cerrar_menu()
		else:
			# 3. Si no le alcanza, pausamos la función para que lea el error
			await mostrar_error_dinero()


# --- BOTÓN ESCUDO ---
func _on_escudo_pressed() -> void:
	# 1. Verificamos si YA lo tiene desbloqueado
	if GameManager.armasDesbloqueadas.get("escudo", false) == true:
		equipar_arma_al_jugador(2)
		cerrar_menu()
	else:
		# 2. Si no lo tiene, intentamos comprarlo
		if GameManager.gastar_monedas(25):
			GameManager.desbloquear_arma("escudo")
			equipar_arma_al_jugador(2)
			cerrar_menu()
		else:
			# 3. Mostramos error sin cerrar el menú todavía
			await mostrar_error_dinero()


# --- BOTÓN VIDA ---
func _on_vida_pressed() -> void:
	if GameManager.comprar_vida(30):
		cerrar_menu()
	else:
		await mostrar_error_dinero()
