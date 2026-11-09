extends Node2D

func _enter_tree() -> void:
	if GameManager:
		GameManager.equipar_arma_inicial()

func _ready() -> void:
	$AudioStreamPlayer.play()
