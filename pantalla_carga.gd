extends Control

@onready var progress: Array
@onready var scene_load_status: int

func _ready() -> void:
	get_tree().paused = false
	ResourceLoader.load_threaded_request(GLOBAL.change_scene)

func _process(delta: float) -> void:
	scene_load_status = ResourceLoader.load_threaded_get_status(GLOBAL.change_scene, progress)
	
	%ProgressBar. value = progress[0] * 100

func _on_progress_bar_value_changed(value: float) -> void:
	if value == 100 and scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		get_tree().call_deferred("change_scene_to_packet", ResourceLoader.load_threaded_get(GLOBAL.change_scene))
	pass # Replace with function body.
