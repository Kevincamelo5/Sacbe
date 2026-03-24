extends Area2D
@export var vida = 5
@export var monedas = 0



func _on_body_entered(body: Node2D) -> void:
	if body.name == "Monedas":
		monedas = monedas + 1
	
	if body.name == "Enemies":
		vida = vida - 1
		
	pass # Replace with function body.
