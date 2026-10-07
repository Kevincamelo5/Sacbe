extends Area2D

signal puerta_golpeada(texto_respuesta, nodo_puerta)

@onready var label_texto: Label = $Label

var texto_actual: String = ""
var esta_activa: bool = true

# --- PALETA MAYA ---
const PALETA_PIEDRA_FONDO := Color("#E8D9BD")
const PALETA_GLIFO_TEXTO := Color("#765D46")
const PALETA_ACENTO_TURQUESA := Color("#009FA1")
const PALETA_BORDE_NEGRO := Color("#000000")

func _ready() -> void:
	_estilizar_label_puerta()

func _estilizar_label_puerta() -> void:
	if not label_texto:
		return
		
	# Estilo placa de piedra
	var style_placa = StyleBoxFlat.new()
	style_placa.bg_color = PALETA_PIEDRA_FONDO
	style_placa.border_color = PALETA_ACENTO_TURQUESA
	style_placa.border_width_left = 3
	style_placa.border_width_right = 3
	style_placa.border_width_top = 3
	style_placa.border_width_bottom = 3
	style_placa.corner_radius_top_left = 8
	style_placa.corner_radius_top_right = 8
	style_placa.corner_radius_bottom_left = 8
	style_placa.corner_radius_bottom_right = 8
	
	# Márgenes internos para que el texto respire
	style_placa.content_margin_left = 16
	style_placa.content_margin_right = 16
	style_placa.content_margin_top = 8
	style_placa.content_margin_bottom = 8
	
	# Sombra
	style_placa.shadow_color = Color(0, 0, 0, 0.5)
	style_placa.shadow_size = 4
	style_placa.shadow_offset = Vector2(2, 2)

	# Aplicar tema
	label_texto.add_theme_stylebox_override("normal", style_placa)
	label_texto.add_theme_color_override("font_color", PALETA_GLIFO_TEXTO)
	label_texto.add_theme_font_size_override("font_size", 32)
	label_texto.add_theme_constant_override("outline_size", 2)
	label_texto.add_theme_color_override("font_outline_color", PALETA_BORDE_NEGRO)
	label_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Permite que se expanda hacia ambos lados al cambiar de texto
	label_texto.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label_texto.grow_vertical = Control.GROW_DIRECTION_BOTH

func configurar_puerta(texto: String) -> void:
	texto_actual = texto
	if label_texto:
		label_texto.text = texto
	esta_activa = true
	visible = true

func recibir_dano(cantidad_dano: int) -> void:
	if not esta_activa:
		return
	puerta_golpeada.emit(texto_actual, self)

# Alias para que el ataque del jugador active la puerta
func lastimar(cantidad_dano: int = 1) -> void:
	recibir_dano(cantidad_dano)

func romper_puerta() -> void:
	esta_activa = false
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 0.1), 0.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	
func castigar_jugador() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1, 0, 0), 0.1)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1)
