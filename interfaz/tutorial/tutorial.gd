extends CanvasLayer

## Pequeño tutorial que se muestra una sola vez, al empezar el Nivel 1.
## Pausa el juego mientras explica los controles y señala las vidas,
## las monedas y el botón de pausa.

const RUTA_FUENTE := "res://activos/fuentes/Mayan.ttf"
const RUTA_CORAZON := "res://componentes/escenarios/Corazon.png"
const RUTA_MONEDA := "res://activos/arte/Coin.png"
const RUTA_CUCHILLO := "res://activos/arte/cuchillo.png"
const RUTA_PAUSA := "res://activos/arte/botones/pause-button-2148106_1280.png"

const COLOR_DORADO := Color(0.86, 0.71, 0.38)
const COLOR_TEXTO := Color(0.94, 0.89, 0.78)
const COLOR_TEXTO_SUAVE := Color(0.76, 0.71, 0.62)

var _fuente: Font
var _paso_actual := 0
var _pasos: Array = []

var _fondo: ColorRect
var _resaltado: Panel
var _etiqueta_resaltado: Label
var _panel: PanelContainer
var _titulo: Label
var _indicador: Label
var _visual: HBoxContainer
var _descripcion: Label
var _btn_anterior: Button
var _btn_siguiente: Button
var _btn_saltar: Button
var _tiempo := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	_fuente = load(RUTA_FUENTE)
	_definir_pasos()
	_crear_interfaz()
	_mostrar_paso(0)
	# El juego queda detenido mientras el jugador lee el tutorial.
	get_tree().paused = true
	_btn_siguiente.call_deferred("grab_focus")


func _process(delta: float) -> void:
	_tiempo += delta
	if _resaltado.visible:
		# Latido suave para llamar la atención sobre el HUD.
		_resaltado.modulate.a = 0.65 + 0.35 * (0.5 + 0.5 * sin(_tiempo * 4.0))


func _definir_pasos() -> void:
	_pasos = [
		{
			"titulo": "Muévete",
			"texto": "Usa las flechas ← y → para caminar y ↑ para saltar.\nTambién puedes usar las teclas A, D y W.",
			"visual": "movimiento",
			"resaltado": "",
		},
		{
			"titulo": "Ataca",
			"texto": "Pulsa F o ESPACIO para atacar con el objeto que llevas.\nEn pantalla, toca el botón de ataque de la derecha.",
			"visual": "ataque",
			"resaltado": "ataque",
		},
		{
			"titulo": "Vidas y monedas",
			"texto": "Tus vidas son los corazones de arriba a la izquierda.\nLas monedas que recojas aparecen justo debajo.",
			"visual": "vidas_monedas",
			"resaltado": "vidas_monedas",
		},
		{
			"titulo": "Pausa",
			"texto": "Pulsa P o toca el botón de pausa, arriba a la derecha,\npara detener el juego y abrir el menú.",
			"visual": "pausa",
			"resaltado": "pausa",
		},
	]


func _crear_interfaz() -> void:
	# Fondo oscuro semitransparente: deja ver el HUD que se está señalando.
	_fondo = ColorRect.new()
	_fondo.color = Color(0.02, 0.03, 0.02, 0.55)
	_fondo.mouse_filter = Control.MOUSE_FILTER_STOP
	_fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_fondo)

	# Recuadro dorado que señala el elemento del HUD de cada paso.
	_resaltado = Panel.new()
	_resaltado.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_resaltado.add_theme_stylebox_override("panel", _crear_estilo_resaltado())
	_resaltado.visible = false
	add_child(_resaltado)

	_etiqueta_resaltado = _crear_etiqueta("", 22, COLOR_DORADO)
	_etiqueta_resaltado.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.9))
	_etiqueta_resaltado.add_theme_constant_override("outline_size", 6)
	_etiqueta_resaltado.visible = false
	add_child(_etiqueta_resaltado)

	# El panel se centra solo, sin importar el tamaño de la ventana.
	var centro := CenterContainer.new()
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(700, 0)
	_panel.add_theme_stylebox_override("panel", _crear_estilo_panel())
	centro.add_child(_panel)

	var margen := MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 32)
	margen.add_theme_constant_override("margin_right", 32)
	margen.add_theme_constant_override("margin_top", 24)
	margen.add_theme_constant_override("margin_bottom", 24)
	_panel.add_child(margen)

	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 16)
	margen.add_child(columna)

	# Encabezado: título del tutorial e indicador de paso.
	var encabezado := HBoxContainer.new()
	encabezado.add_theme_constant_override("separation", 12)
	columna.add_child(encabezado)

	_titulo = _crear_etiqueta("", 36, COLOR_DORADO)
	_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	encabezado.add_child(_titulo)

	_indicador = _crear_etiqueta("", 20, COLOR_TEXTO_SUAVE)
	_indicador.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	encabezado.add_child(_indicador)

	# Dibujo grande de los controles de cada paso.
	_visual = HBoxContainer.new()
	_visual.alignment = BoxContainer.ALIGNMENT_CENTER
	_visual.add_theme_constant_override("separation", 14)
	_visual.custom_minimum_size = Vector2(0, 92)
	columna.add_child(_visual)

	_descripcion = _crear_etiqueta("", 25, COLOR_TEXTO)
	_descripcion.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_descripcion.custom_minimum_size = Vector2(620, 72)
	_descripcion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_descripcion.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	columna.add_child(_descripcion)

	# Botones de navegación.
	var fila_botones := HBoxContainer.new()
	fila_botones.add_theme_constant_override("separation", 12)
	columna.add_child(fila_botones)

	_btn_saltar = _crear_boton("Saltar tutorial")
	_btn_saltar.pressed.connect(_saltar_tutorial)
	fila_botones.add_child(_btn_saltar)

	var separador := Control.new()
	separador.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	separador.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila_botones.add_child(separador)

	_btn_anterior = _crear_boton("Anterior")
	_btn_anterior.pressed.connect(_anterior)
	fila_botones.add_child(_btn_anterior)

	_btn_siguiente = _crear_boton("Siguiente")
	_btn_siguiente.pressed.connect(_siguiente)
	fila_botones.add_child(_btn_siguiente)


func _mostrar_paso(indice: int) -> void:
	_paso_actual = clampi(indice, 0, _pasos.size() - 1)
	var paso: Dictionary = _pasos[_paso_actual]

	_titulo.text = paso["titulo"]
	_descripcion.text = paso["texto"]
	_indicador.text = "Paso %d de %d" % [_paso_actual + 1, _pasos.size()]
	_btn_anterior.disabled = _paso_actual == 0
	_btn_siguiente.text = "¡A jugar!" if _paso_actual == _pasos.size() - 1 else "Siguiente"

	_actualizar_visual(paso["visual"])
	_actualizar_resaltado(paso["resaltado"])

	if is_inside_tree():
		_btn_siguiente.grab_focus()


func _actualizar_visual(tipo: String) -> void:
	for hijo in _visual.get_children():
		_visual.remove_child(hijo)
		hijo.queue_free()

	match tipo:
		"movimiento":
			_visual.add_child(_crear_tecla("←"))
			_visual.add_child(_crear_tecla("→"))
			_visual.add_child(_crear_etiqueta("moverse", 22, COLOR_TEXTO_SUAVE))
			_visual.add_child(_crear_separador_visual(22))
			_visual.add_child(_crear_tecla("↑"))
			_visual.add_child(_crear_etiqueta("saltar", 22, COLOR_TEXTO_SUAVE))
		"ataque":
			_visual.add_child(_crear_tecla("F"))
			_visual.add_child(_crear_etiqueta("o", 22, COLOR_TEXTO_SUAVE))
			_visual.add_child(_crear_tecla("ESPACIO", 20))
			_visual.add_child(_crear_espacio_horizontal(10))
			_visual.add_child(_crear_icono(RUTA_CUCHILLO, 56))
		"vidas_monedas":
			_visual.add_child(_crear_icono(RUTA_CORAZON, 48))
			_visual.add_child(_crear_etiqueta("Vidas", 24, COLOR_TEXTO))
			_visual.add_child(_crear_separador_visual(24))
			_visual.add_child(_crear_icono_moneda(48))
			_visual.add_child(_crear_etiqueta("Monedas", 24, COLOR_TEXTO))
		"pausa":
			_visual.add_child(_crear_icono(RUTA_PAUSA, 58))
			_visual.add_child(_crear_tecla("P"))
			_visual.add_child(_crear_etiqueta("pausa", 22, COLOR_TEXTO_SUAVE))


func _actualizar_resaltado(tipo: String) -> void:
	if tipo == "":
		_resaltado.visible = false
		_etiqueta_resaltado.visible = false
		return

	var zona := _zona_resaltada(tipo)
	if zona.size == Vector2.ZERO:
		_resaltado.visible = false
		_etiqueta_resaltado.visible = false
		return

	_resaltado.visible = true
	_resaltado.position = zona.position
	_resaltado.size = zona.size

	var textos := {
		"ataque": "Botón de ataque",
		"vidas_monedas": "Vidas y monedas",
		"pausa": "Botón de pausa",
	}
	_etiqueta_resaltado.text = textos.get(tipo, "")
	_etiqueta_resaltado.visible = _etiqueta_resaltado.text != ""
	_etiqueta_resaltado.reset_size()

	# Mantenemos la etiqueta dentro de la pantalla (el botón de pausa está
	# pegado al borde derecho).
	var tam := get_viewport().get_visible_rect().size
	var ancho_etiqueta := _etiqueta_resaltado.get_combined_minimum_size().x
	var alto_etiqueta := _etiqueta_resaltado.get_combined_minimum_size().y
	var x := clampf(zona.position.x, 8.0, maxf(8.0, tam.x - ancho_etiqueta - 8.0))
	var y := zona.end.y + 6.0
	if y + alto_etiqueta > tam.y - 6.0:
		y = zona.position.y - alto_etiqueta - 6.0
	_etiqueta_resaltado.position = Vector2(x, y)


func _zona_resaltada(tipo: String) -> Rect2:
	var tam := get_viewport().get_visible_rect().size
	match tipo:
		"ataque":
			return Rect2(tam.x - 205.0, tam.y - 195.0, 160.0, 160.0)
		"vidas_monedas":
			return Rect2(38.0, 18.0, 345.0, 128.0)
		"pausa":
			return Rect2(tam.x - 125.0, 10.0, 112.0, 100.0)
	return Rect2()


# --- Botones e input ---

func _anterior() -> void:
	_mostrar_paso(_paso_actual - 1)


func _siguiente() -> void:
	if _paso_actual >= _pasos.size() - 1:
		_cerrar_tutorial()
	else:
		_mostrar_paso(_paso_actual + 1)


func _saltar_tutorial() -> void:
	_cerrar_tutorial()


func _cerrar_tutorial() -> void:
	if GameManager:
		GameManager.tutorial_visto = true
	if is_inside_tree():
		get_tree().paused = false
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	# Enter/Espacio avanzan y Escape cierra el tutorial.
	if event.is_action_pressed("ui_cancel"):
		_saltar_tutorial()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_siguiente()
		get_viewport().set_input_as_handled()


# --- Constructores de interfaz ---

func _crear_estilo_panel() -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.09, 0.07, 0.05, 0.96)
	estilo.border_color = COLOR_DORADO
	estilo.set_border_width_all(3)
	estilo.set_corner_radius_all(12)
	estilo.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
	estilo.shadow_size = 12
	return estilo


func _crear_estilo_resaltado() -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(1.0, 0.84, 0.35, 0.10)
	estilo.border_color = Color(1.0, 0.86, 0.40, 1.0)
	estilo.set_border_width_all(3)
	estilo.set_corner_radius_all(10)
	return estilo


func _crear_etiqueta(texto: String, tamano: int, color: Color) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.add_theme_font_override("font", _fuente)
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	etiqueta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	etiqueta.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return etiqueta


func _crear_tecla(texto: String, tamano: int = 28) -> PanelContainer:
	var tecla := PanelContainer.new()
	tecla.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.23, 0.19, 0.13, 1.0)
	estilo.border_color = Color(0.78, 0.64, 0.36, 1.0)
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(8)
	estilo.content_margin_left = 14
	estilo.content_margin_right = 14
	estilo.content_margin_top = 10
	estilo.content_margin_bottom = 10
	tecla.add_theme_stylebox_override("panel", estilo)

	# Sin fuente personalizada para que las flechas siempre se dibujen bien.
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", COLOR_TEXTO)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	etiqueta.custom_minimum_size = Vector2(42, 42)
	tecla.add_child(etiqueta)
	return tecla


func _crear_boton(texto: String) -> Button:
	var boton := Button.new()
	boton.text = texto
	boton.add_theme_font_override("font", _fuente)
	boton.add_theme_font_size_override("font_size", 22)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.18, 0.15, 0.11, 0.95)
	normal.border_color = Color(0.62, 0.50, 0.28, 0.9)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(6)
	normal.content_margin_left = 16
	normal.content_margin_right = 16
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.34, 0.27, 0.15, 1.0)
	hover.border_color = Color(1.0, 0.88, 0.45, 1.0)

	var pressed := hover.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.46, 0.37, 0.18, 1.0)

	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(0.12, 0.10, 0.08, 0.55)
	disabled.border_color = Color(0.42, 0.37, 0.28, 0.45)

	boton.add_theme_stylebox_override("normal", normal)
	boton.add_theme_stylebox_override("hover", hover)
	boton.add_theme_stylebox_override("pressed", pressed)
	boton.add_theme_stylebox_override("focus", hover)
	boton.add_theme_stylebox_override("disabled", disabled)

	boton.add_theme_color_override("font_color", COLOR_TEXTO)
	boton.add_theme_color_override("font_hover_color", Color(1.0, 0.96, 0.72))
	boton.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0))
	boton.add_theme_color_override("font_disabled_color", Color(0.55, 0.51, 0.44))
	return boton


func _crear_icono(ruta: String, tamano: float) -> TextureRect:
	var textura := load(ruta) as Texture2D
	return _crear_icono_textura(textura, tamano)


func _crear_icono_moneda(tamano: float) -> TextureRect:
	var imagen := load(RUTA_MONEDA) as Texture2D
	var atlas := AtlasTexture.new()
	atlas.atlas = imagen
	# Coin.png es una hoja de 3x3; usamos el primer cuadro (la moneda completa).
	atlas.region = Rect2(Vector2.ZERO, Vector2(imagen.get_width() / 3.0, imagen.get_height() / 3.0))
	return _crear_icono_textura(atlas, tamano)


func _crear_icono_textura(textura: Texture2D, tamano: float) -> TextureRect:
	var icono := TextureRect.new()
	icono.texture = textura
	icono.custom_minimum_size = Vector2(tamano, tamano)
	icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icono.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return icono


func _crear_separador_visual(ancho: float) -> Control:
	var separador := Control.new()
	separador.custom_minimum_size = Vector2(ancho, 0)
	separador.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return separador


func _crear_espacio_horizontal(ancho: float) -> Control:
	var espacio := Control.new()
	espacio.custom_minimum_size = Vector2(ancho, 0)
	espacio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return espacio
