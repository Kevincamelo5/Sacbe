extends Node2D

# Variables para controlar el progreso
var monedas_recogidas: int = 0
var total_monedas: int = 15

const ARMAS_MEJORABLES := ["cuchillo", "hacha", "lanza", "macuahuitle"]

@onready var label_contador: Label = $CanvasLayer2/PanelMonedasEspeciales/ContenedorMonedasEspeciales/LabelMonedasEspeciales
@onready var boton_tienda: Button = $CanvasLayer2/BotonTienda
@onready var label_mensaje: Label = $CanvasLayer2/LabelMensaje
@onready var tienda: CanvasLayer = $TiendaMejora
@onready var label_descripcion: Label = $TiendaMejora/Centro/Panel/VBox/Descripcion
@onready var label_estado: Label = $TiendaMejora/Centro/Panel/VBox/LabelEstado
@onready var boton_mejorar: Button = $TiendaMejora/Centro/Panel/VBox/BotonMejorar
@onready var boton_cerrar: Button = $TiendaMejora/Centro/Panel/VBox/BotonCerrar

func _enter_tree() -> void:
	if GameManager:
		GameManager.equipar_arma_inicial()

func _ready() -> void:
	tienda.visible = false
	boton_tienda.hide()
	label_mensaje.hide()
	label_estado.hide()
	
	boton_tienda.pressed.connect(_abrir_tienda_mejora)
	boton_mejorar.pressed.connect(_mejorar_arma_actual)
	boton_cerrar.pressed.connect(_cerrar_tienda)
	
	if not GameManager.arma_cambiada.is_connected(_actualizar_boton_tienda):
		GameManager.arma_cambiada.connect(_actualizar_boton_tienda)
	
	actualizar_texto()

func recolectar_moneda_especial() -> void:
	monedas_recogidas += 1
	actualizar_texto()
	
	# Al completar las 15 monedas se abre la tienda de mejoras.
	if monedas_recogidas >= total_monedas:
		_abrir_tienda_mejora()

func actualizar_texto() -> void:
	label_contador.text = str(monedas_recogidas) + " / " + str(total_monedas) + " Monedas especiales"
	_actualizar_boton_tienda()

func _actualizar_boton_tienda() -> void:
	var arma := str(GameManager.arma_equipada_actual)
	var tiene_monedas := monedas_recogidas >= total_monedas
	var ya_mejorada := GameManager.arma_esta_mejorada(arma)
	boton_tienda.visible = tiene_monedas and not ya_mejorada and not tienda.visible
	boton_tienda.disabled = not tiene_monedas

func _abrir_tienda_mejora() -> void:
	if tienda.visible:
		return
	
	if monedas_recogidas < total_monedas:
		mostrar_mensaje("Necesitas juntar las 15 monedas especiales.")
		return
	
	_actualizar_estado_tienda()
	tienda.visible = true
	boton_tienda.hide()
	get_tree().paused = true

func _actualizar_estado_tienda() -> void:
	var arma := str(GameManager.arma_equipada_actual)
	label_descripcion.text = "Mejora tu arma actual (%s) usando 15 monedas especiales.\nSolo un arma mejorada puede dañar a Huay." % arma.capitalize()
	label_estado.hide()
	
	if not ARMAS_MEJORABLES.has(arma):
		boton_mejorar.text = "Equipa un arma de ataque"
		boton_mejorar.disabled = true
		_mostrar_estado("Cambia a hacha, lanza, cuchillo o macuahuitle para poder mejorarla.")
	elif GameManager.arma_esta_mejorada(arma):
		boton_mejorar.text = "Arma ya mejorada"
		boton_mejorar.disabled = true
	elif monedas_recogidas < total_monedas:
		boton_mejorar.text = "Faltan monedas especiales"
		boton_mejorar.disabled = true
	else:
		boton_mejorar.text = "Mejorar arma actual (15)"
		boton_mejorar.disabled = false

func _mejorar_arma_actual() -> void:
	var arma := str(GameManager.arma_equipada_actual)
	
	if monedas_recogidas < total_monedas:
		_mostrar_estado("Necesitas 15 monedas especiales.")
		return
	
	if not ARMAS_MEJORABLES.has(arma):
		_mostrar_estado("Ese objeto no se puede mejorar para atacar.")
		return
	
	if not GameManager.mejorar_arma(arma):
		_mostrar_estado("Tu arma actual ya está mejorada.")
		return
	
	monedas_recogidas -= total_monedas
	actualizar_texto()
	boton_mejorar.disabled = true
	_mostrar_estado("¡%s mejorada! Ya puede dañar a Huay." % arma.capitalize())
	await get_tree().create_timer(2.0).timeout
	_cerrar_tienda()
	mostrar_mensaje("¡Arma mejorada! Busca a Huay.")

func _mostrar_estado(texto: String) -> void:
	label_estado.text = texto
	label_estado.show()

func _cerrar_tienda() -> void:
	tienda.visible = false
	get_tree().paused = false
	_actualizar_boton_tienda()

func mostrar_mensaje(texto: String) -> void:
	label_mensaje.text = texto
	label_mensaje.show()
	await get_tree().create_timer(2.5).timeout
	label_mensaje.hide()
