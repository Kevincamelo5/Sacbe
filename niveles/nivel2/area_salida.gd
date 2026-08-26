extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_area_salida_body_entered(body: Node2D) -> void:
	print("Entró algo al área")
	if body.name == "Jugador":
		get_tree().change_scene_to_file("res://niveles/nivel2/batalla_jabali.tscn")
