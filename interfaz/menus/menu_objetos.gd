extends CanvasLayer

func _ready() -> void:
	visible = false
	mostrar()

func mostrar():
	var tree = get_tree()
	if tree:
		visible = true
		tree.paused = true
	else:
		print("Error: El SceneTree no está disponible todavía.")

func _on_hacha_pressed() -> void:
	visible = false
	get_tree().paused = false
	pass # Replace with function body.


func _on_lanza_pressed() -> void:
	visible = false
	get_tree().paused = false
	pass # Replace with function body.


func _on_cuchillo_pressed() -> void:
	visible = false
	get_tree().paused = false
	pass # Replace with function body.


func _on_macuahuitle_pressed() -> void:
	visible = false
	get_tree().paused = false
	pass # Replace with function body.


func _on_flauta_pressed() -> void:
	visible = false
	get_tree().paused = false
	pass # Replace with function body.


func _on_escudo_pressed() -> void:
	visible = false
	get_tree().paused = false
	pass # Replace with function body.
