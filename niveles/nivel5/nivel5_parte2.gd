extends Node2D
## Arena del combate final contra Kakasbal (Nivel 5, parte 2).
## Quitzal entra por la izquierda y Kakasbal aparece convertido en ave.

@onready var kakasbal: CharacterBody2D = $Kakasbal
@onready var musica: AudioStreamPlayer = $Musica

func _ready() -> void:
	if musica:
		musica.play()
	if kakasbal:
		kakasbal.jefe_derrotado.connect(_on_jefe_derrotado)
	_intro()

func _intro() -> void:
	if kakasbal:
		kakasbal.modulate.a = 0.0
		var tween := create_tween()
		tween.tween_property(kakasbal, "modulate:a", 1.0, 1.2)
		tween.parallel().tween_property(kakasbal, "scale", Vector2(1.0, 1.0), 1.2).from(Vector2(0.8, 0.8))

func _on_jefe_derrotado() -> void:
	await get_tree().create_timer(1.2).timeout
	get_tree().change_scene_to_file("res://niveles/nivel5/nivel5_cinematica_final.tscn")
