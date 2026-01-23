extends Node2D

@onready var game_manager: Node = $GameManager

func _on_moneda_area_entered(area: Area2D) -> void:
	
	pass # Replace with function body.


func _on_moneda_body_entered(body: Node2D) -> void:
	#game_manager.incrementar_monedas()
	queue_free()
	pass # Replace with function body.
