extends CanvasLayer


#funcion dice si un cuadro es visible
func _ready() -> void:
	visible=false

func mostrar():
	visible = true 
	get_tree().paused=true #pausa el juego
