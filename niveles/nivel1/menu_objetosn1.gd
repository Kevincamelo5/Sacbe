extends CanvasLayer

var costoH = 30
var costoE = 25

func _ready() -> void:
	
	#permite que el menú, los botones y el timer funcionen mientras el juego esta en pausa
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	$noteAlcanza.hide()

func mostrar():
	var tree = get_tree()
	if tree:
		visible = true
		tree.paused = true
	else:
		print("Error: El SceneTree no está disponible todavía.")

# Función auxiliar para equipar el arma en el jugador al instante
func equipar_arma_al_jugador(id_arma: int):
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		jugador.objetoActual = id_arma

# --- FUNCIÓN AUXILIAR PARA EL MENSAJE DE ERROR ---
func mostrar_error_dinero():
	$noteAlcanza.show()
	$Timer.start(3.0)
	await $Timer.timeout
	$noteAlcanza.hide()

func _on_hacha_pressed() -> void:
	# Intentamos cobrar 35 monedas
	if GameManager.gastar_monedas(35):
		GameManager.desbloquear_arma("hacha")
		equipar_arma_al_jugador(3) 
		cerrar_menu()
	else:
		mostrar_error_dinero()


func _on_escudo_pressed() -> void:
	# Intentamos cobrar 25 monedas
	if GameManager.gastar_monedas(25):
		GameManager.desbloquear_arma("escudo")
		equipar_arma_al_jugador(2)
		cerrar_menu()
	else:
		mostrar_error_dinero()

func cerrar_menu():
	visible = false
	get_tree().paused = false

func _on_vida_pressed() -> void:
	# Intentamos comprar la vida por 30 monedas
	if GameManager.comprar_vida(30):
		cerrar_menu()
	else:
		mostrar_error_dinero()
