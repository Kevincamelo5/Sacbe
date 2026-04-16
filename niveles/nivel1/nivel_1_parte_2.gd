extends Node2D


#funcion dice si un cuadro es visible
func _ready() -> void:
	$musicadefondo.play()

func mostrar():
	visible = true 
	get_tree().paused=true #pausa el juego
