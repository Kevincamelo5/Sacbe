extends Area2D
@export var vida = 5
@export var monedas = 0



func _on_body_entered(body: Node2D) -> void:
	if body.name == "Monedas":
		monedas = monedas + 1
	print(monedas)
	
	if body.name == "Enemies":
		vida = vida - 1
	print(vida	)
	pass # Replace with function body.
