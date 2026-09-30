extends Control

@onready var boton_continuar = $BotonContinuar

func _ready() -> void:
	# Conectamos el botón por código
	boton_continuar.pressed.connect(_avanzar_siguiente_nivel)

func _avanzar_siguiente_nivel() -> void:
	# Aquí ponemos la ruta del nivel al que ibas a ir originalmente
	get_tree().change_scene_to_file("res://niveles/nivel2/nivel2_restador2.tscn")
