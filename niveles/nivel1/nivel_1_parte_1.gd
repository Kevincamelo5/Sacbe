extends Node2D

const ESCENA_TUTORIAL := preload("res://interfaz/tutorial/tutorial.tscn")

func _enter_tree() -> void:
	if GameManager:
		GameManager.equipar_arma_inicial()

func _ready() -> void:
	$AudioStreamPlayer.play()
	_mostrar_tutorial_inicial()

## Muestra el tutorial solo la primera vez que se juega el Nivel 1.
func _mostrar_tutorial_inicial() -> void:
	if GameManager == null or GameManager.tutorial_visto:
		return
	
	# Lo marcamos antes de mostrarlo para que no vuelva a aparecer al reiniciar
	# el nivel (por ejemplo, después de perder una vida).
	GameManager.tutorial_visto = true
	var tutorial := ESCENA_TUTORIAL.instantiate()
	add_child(tutorial)
