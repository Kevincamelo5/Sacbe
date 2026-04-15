extends CanvasLayer

@onready var texto_vidas: Label = $TextoVidas 

func _ready() -> void:
	# 1. Intentamos obtener el GameManager desde la raíz (Autoload)
	var gm = get_node_or_null("/root/GameManager")
	
	if gm:
		# 2. Conectamos la señal para futuros cambios
		if not gm.vida_actualizada.is_connected(_on_vida_actualizada):
			gm.vida_actualizada.connect(_on_vida_actualizada)
		
		# 3. ¡IMPORTANTE!: Actualizar el texto inmediatamente al cargar
		# Esto garantiza que tras el reload_current_scene, el HUD lea la vida actual
		_on_vida_actualizada(gm.vida)

func _on_vida_actualizada(nueva_vida: int) -> void:
	if texto_vidas:
		texto_vidas.text = str(nueva_vida)
