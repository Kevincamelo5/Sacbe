extends Node2D

# Variables para controlar el progreso
var monedas_recogidas: int = 0
var total_monedas: int = 15

# Referencia a la etiqueta de texto que creaste
@onready var label_contador: Label = $CanvasLayer2/LabelMonedasEspeciales

func _ready() -> void:
	# Actualizamos el texto apenas carga el nivel
	actualizar_texto()

func recolectar_moneda_especial() -> void:
	monedas_recogidas += 1
	actualizar_texto()
	
	# Comprobar si ya se recogieron todas
	if monedas_recogidas >= total_monedas:
		print("¡Completaste el objetivo de las monedas especiales!")
		# Aquí puedes llamar a una función para abrir una puerta, dar un trofeo, etc.

func actualizar_texto() -> void:
	label_contador.text = str(monedas_recogidas) + " / " + str(total_monedas) + " Monedas especiales"
