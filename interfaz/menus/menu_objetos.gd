extends CanvasLayer

func _ready() -> void:
	visible = false
	mostrar()
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

func _on_hacha_pressed() -> void:
	GameManager.desbloquear_arma("hacha")
	equipar_arma_al_jugador(3) # 3 es el ID del Hacha en tu enum del jugador
	cerrar_menu()

func _on_lanza_pressed() -> void:
	GameManager.desbloquear_arma("lanza")
	equipar_arma_al_jugador(1) # 1 es el ID de la Lanza
	cerrar_menu()

func _on_cuchillo_pressed() -> void:
	# El cuchillo ya está desbloqueado, solo lo equipamos
	equipar_arma_al_jugador(0)
	cerrar_menu()

func _on_macuahuitle_pressed() -> void:
	GameManager.desbloquear_arma("macuahuitle")
	equipar_arma_al_jugador(4)
	cerrar_menu()

func _on_flauta_pressed() -> void:
	GameManager.desbloquear_arma("flauta")
	equipar_arma_al_jugador(5)
	cerrar_menu()

func _on_escudo_pressed() -> void:
	GameManager.desbloquear_arma("escudo")
	equipar_arma_al_jugador(2)
	cerrar_menu()

func cerrar_menu():
	visible = false
	get_tree().paused = false

func _on_vida_pressed() -> void:
	var compra_exitosa = GameManager.comprar_vida(30)
	if compra_exitosa:
		pass
	else:
		$noteAlcanza.show()
		$Timer.start(3.0)
		await $Timer.timeout
		$noteAlcanza.hide()
	cerrar_menu()
	pass # Replace with function body.
