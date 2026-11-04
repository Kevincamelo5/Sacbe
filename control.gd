extends Control

@onready var boton_continuar = $Continuar

func _ready() -> void:
	# Conectamos el botón por código
	boton_continuar.pressed.connect(_avanzar_siguiente_nivel)

func _avanzar_siguiente_nivel() -> void:
	# Reiniciamos las vidas al empezar el nuevo nivel
	GameManager.reiniciar_estado()
	get_tree().change_scene_to_file("res://niveles/nivel2/nivel2_parte1.tscn")
