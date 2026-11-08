extends CanvasLayer

const MENU_PAUSA := preload("res://interfaz/menus/menu_pausa.tscn")

@onready var _boton: TextureButton = $Boton


func _ready() -> void:
	_boton.pressed.connect(_abrir_pausa)


func _abrir_pausa() -> void:
	if get_tree().paused:
		return

	var menu := MENU_PAUSA.instantiate()
	add_child(menu)
	get_tree().paused = true
