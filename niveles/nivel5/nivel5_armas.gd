extends Control
## Menú de selección / compra de armas antes del combate final contra Kakasbal.
## El jugador puede equipar cualquier arma que ya haya desbloqueado a lo largo de
## la partida, o comprar las que le falten con las monedas de cacao acumuladas.

@export_file("*.tscn") var next_scene: String = "res://niveles/nivel5/nivel5_parte2.tscn"

const PALETA_PIEDRA_FONDO := Color("#E8D9BD")
const PALETA_GLIFO_TEXTO := Color("#765D46")
const PALETA_ACENTO_TURQUESA := Color("#009FA1")
const PALETA_BORDE_NEGRO := Color("#000000")

const ARMAS := [
	{"id": "cuchillo", "titulo": "Cuchillo", "costo": 0, "icono": "res://activos/arte/cuchillo.png"},
	{"id": "lanza", "titulo": "Lanza", "costo": 30, "icono": "res://componentes/escenarios/lanza-test.png"},
	{"id": "escudo", "titulo": "Escudo", "costo": 25, "icono": "res://activos/arte/(256) Escudo.png"},
	{"id": "hacha", "titulo": "Hacha", "costo": 40, "icono": "res://componentes/escenarios/hacha-test.png"},
	{"id": "flauta", "titulo": "Flauta", "costo": 35, "icono": "res://componentes/escenarios/flauta-test.png"},
	{"id": "macuahuitle", "titulo": "Macuahuitl", "costo": 50, "icono": "res://activos/arte/(512) Quitzal macuahuitle v2 frentre.png"},
]

var _monedas_label: Label
var _nota: Label
var _tarjetas: Array = []  # Cada elemento es un Dictionary con "arma", "estado" (Label) y "boton" (Button)

func _ready() -> void:
	_construir_ui()

func _construir_ui() -> void:
	# Fondo
	var fondo := TextureRect.new()
	fondo.texture = load("res://niveles/nivel5/Fondo-Lv5.png")
	fondo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fondo.stretch_mode = TextureRect.STRETCH_SCALE
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)

	# Velo oscuro para legibilidad
	var velo := ColorRect.new()
	velo.color = Color(0.05, 0.02, 0.0, 0.72)
	velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(velo)

	# Contenedor principal
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 60
	vbox.offset_top = 30
	vbox.offset_right = -60
	vbox.offset_bottom = -30
	vbox.add_theme_constant_override("separation", 16)
	add_child(vbox)

	# Título
	var titulo := Label.new()
	titulo.text = "Elige tu arma para la batalla final"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 30)
	titulo.add_theme_color_override("font_color", Color(0.95, 0.88, 0.75))
	titulo.add_theme_constant_override("outline_size", 4)
	titulo.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	vbox.add_child(titulo)

	# Monedas
	_monedas_label = Label.new()
	_monedas_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_monedas_label.add_theme_font_size_override("font_size", 22)
	_monedas_label.add_theme_color_override("font_color", Color(1, 0.96, 0.7))
	_monedas_label.add_theme_constant_override("outline_size", 3)
	_monedas_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	vbox.add_child(_monedas_label)

	# Cuadrícula de armas (dentro de un ScrollContainer por si no cabe en pantalla)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	scroll.add_child(grid)

	for arma in ARMAS:
		grid.add_child(_crear_tarjeta(arma))

	# Nota de avisos
	_nota = Label.new()
	_nota.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_nota.add_theme_font_size_override("font_size", 18)
	_nota.add_theme_color_override("font_color", Color(1, 0.85, 0.5))
	_nota.add_theme_constant_override("outline_size", 2)
	_nota.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	_nota.text = ""
	vbox.add_child(_nota)

	# Botón continuar
	var btn_continuar := Button.new()
	btn_continuar.text = "Continuar al combate"
	btn_continuar.custom_minimum_size = Vector2(0, 48)
	btn_continuar.add_theme_font_size_override("font_size", 26)
	_estilizar_boton(btn_continuar, PALETA_ACENTO_TURQUESA)
	btn_continuar.pressed.connect(_ir_al_combate)
	vbox.add_child(btn_continuar)

	_actualizar_ui()

func _crear_tarjeta(arma: Dictionary) -> Control:
	var panel := PanelContainer.new()
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.12, 0.10, 0.08, 0.92)
	estilo.border_color = Color(0.85, 0.70, 0.35, 1.0)
	estilo.set_border_width_all(3)
	estilo.set_corner_radius_all(10)
	estilo.content_margin_left = 12
	estilo.content_margin_right = 12
	estilo.content_margin_top = 12
	estilo.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", estilo)

	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 6)
	panel.add_child(columna)

	# Icono del arma
	var icono := TextureRect.new()
	icono.texture = load(arma["icono"])
	icono.custom_minimum_size = Vector2(64, 64)
	icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	columna.add_child(icono)

	# Nombre del arma
	var nombre := Label.new()
	nombre.text = arma["titulo"]
	nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nombre.add_theme_font_size_override("font_size", 20)
	nombre.add_theme_color_override("font_color", Color(0.95, 0.88, 0.75))
	nombre.add_theme_constant_override("outline_size", 2)
	nombre.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	columna.add_child(nombre)

	# Estado (Equipado / Desbloqueado / Costo)
	var estado := Label.new()
	estado.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	estado.add_theme_font_size_override("font_size", 16)
	estado.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	columna.add_child(estado)

	# Botón de acción
	var boton := Button.new()
	boton.custom_minimum_size = Vector2(0, 38)
	boton.add_theme_font_size_override("font_size", 18)
	boton.pressed.connect(_on_boton_arma_pressed.bind(arma))
	columna.add_child(boton)

	_tarjetas.append({"arma": arma, "estado": estado, "boton": boton})
	return panel

func _on_boton_arma_pressed(arma: Dictionary) -> void:
	var id: String = arma["id"]
	if GameManager.armasDesbloqueadas.get(id, false):
		_equipar(id)
	else:
		var costo: int = arma["costo"]
		if GameManager.gastar_monedas(costo):
			GameManager.desbloquear_arma(id)
			_equipar(id)
			_mostrar_nota("¡Compraste %s!" % arma["titulo"])
		else:
			_mostrar_nota("Monedas insuficientes. Necesitas %d." % costo)
	_actualizar_ui()

func _equipar(id: String) -> void:
	GameManager.arma_equipada_actual = id
	if GameManager.has_signal("arma_cambiada"):
		GameManager.arma_cambiada.emit()
	_mostrar_nota("Arma equipada: %s" % _titulo_de(id))

func _titulo_de(id: String) -> String:
	for arma in ARMAS:
		if arma["id"] == id:
			return arma["titulo"]
	return id

func _mostrar_nota(texto: String) -> void:
	if _nota:
		_nota.text = texto

func _actualizar_ui() -> void:
	if _monedas_label:
		_monedas_label.text = "Monedas: %d" % GameManager.moneda

	var equipada: String = GameManager.arma_equipada_actual
	for tarjeta in _tarjetas:
		var arma: Dictionary = tarjeta["arma"]
		var estado: Label = tarjeta["estado"]
		var boton: Button = tarjeta["boton"]
		var id: String = arma["id"]
		var desbloqueada: bool = GameManager.armasDesbloqueadas.get(id, false)

		if id == equipada:
			estado.text = "Equipado"
			estado.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
			boton.text = "Equipado"
			boton.disabled = true
			_estilizar_boton(boton, Color(0.3, 0.3, 0.3))
		elif desbloqueada:
			estado.text = "Desbloqueado"
			estado.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
			boton.text = "Equipar"
			boton.disabled = false
			_estilizar_boton(boton, PALETA_ACENTO_TURQUESA)
		else:
			estado.text = "Costo: %d" % arma["costo"]
			estado.add_theme_color_override("font_color", Color(0.9, 0.7, 0.4))
			boton.text = "Comprar (%d)" % arma["costo"]
			boton.disabled = false
			_estilizar_boton(boton, Color(0.6, 0.4, 0.2))

func _estilizar_boton(boton: Button, acento: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = acento.darkened(0.15)
	normal.border_color = PALETA_BORDE_NEGRO
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(6)
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = acento.lightened(0.15)
	hover.border_color = Color(1.0, 0.88, 0.45)

	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = acento.darkened(0.3)

	boton.add_theme_stylebox_override("normal", normal)
	boton.add_theme_stylebox_override("hover", hover)
	boton.add_theme_stylebox_override("pressed", pressed)
	boton.add_theme_stylebox_override("focus", hover)
	boton.add_theme_stylebox_override("disabled", normal)
	boton.add_theme_color_override("font_color", Color(0.95, 0.92, 0.85))
	boton.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	boton.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
	boton.add_theme_color_override("font_disabled_color", Color(0.6, 0.6, 0.6))

func _ir_al_combate() -> void:
	if next_scene != "":
		get_tree().change_scene_to_file(next_scene)
	else:
		push_error("nivel5_armas.gd: next_scene no definido")
