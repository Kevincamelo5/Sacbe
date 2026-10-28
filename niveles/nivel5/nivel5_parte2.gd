extends Node2D
## Arena del combate final contra Kakasbal (Nivel 5).
## Cada vez que se carga esta escena se enfrenta UNA forma del jefe
## (ave -> jaguar -> humano). Al vencerla, se avanza a la siguiente
## operación matemática (indicada por GameManager.siguiente_tras_fase).

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
	var destino := "res://niveles/nivel5/nivel5_cinematica_final.tscn"
	if GameManager and str(GameManager.get("siguiente_tras_fase")) != "":
		destino = GameManager.siguiente_tras_fase
	get_tree().change_scene_to_file(destino)
