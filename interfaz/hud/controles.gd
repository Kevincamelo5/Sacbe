extends CanvasLayer



func _on_izquierda_pressed() -> void:
	$Izquierda.modulate=Color(1,1,1,0.5)

func _on_izquierda_released() -> void:
	$Izquierda.modulate=Color(1,1,1,1)

func _on_derecha_pressed() -> void:
	$Derecha.modulate=Color(1,1,1,0.5) # Replace with function body.
	
func _on_derecha_released() -> void:
	$Derecha.modulate=Color(1,1,1,1) # Replace with function body.

func _on_saltar_pressed() -> void:
	$Saltar.modulate=Color(1,1,1,0.5) # Replace with function body.

func _on_saltar_released() -> void:
	$Saltar.modulate=Color(1,1,1,1) # Replace with function body.

func _on_agacharse_pressed() -> void:
	$Agacharse.modulate=Color(1,1,1,0.5) # Replace with function body.

func _on_agacharse_released() -> void:
	$Agacharse.modulate=Color(1,1,1,1) # Replace with function body.

func _on_pausa_pressed() -> void:
	$Pausa.modulate=Color(1,1,1,0.5) # Replace with function body.

func _on_pausa_released() -> void:
	$Pausa.modulate=Color(1,1,1,1) # Replace with function body.

func _on_cambiar_objeto_pressed() -> void:
	$CambiarObjeto.modulate=Color(1,1,1,0.5) # Replace with function body.

func _on_cambiar_objeto_released() -> void:
	$CambiarObjeto.modulate=Color(1,1,1,1) # Replace with function body.

func _on_usar_objeto_pressed() -> void:
	$UsarObjeto.modulate=Color(1,1,1,0.5) # Replace with function body.

func _on_usar_objeto_released() -> void:
	$UsarObjeto.modulate=Color(1,1,1,1) # Replace with function body.

#Referencias
# Variable para habilitar el botón desde el Inspector en el nivel final
@export var es_ultimo_nivel: bool = false

@export_category("Iconos de Armas")
@export var icono_cuchillo: Texture2D
@export var icono_lanza: Texture2D
@export var icono_escudo: Texture2D
@export var icono_hacha: Texture2D
@export var icono_flauta: Texture2D
@export var icono_macuahuitle: Texture2D

@onready var boton_usar = $UsarObjeto

#Referencias
@onready var CambiarObjeto = $CambiarObjeto

#indice actual de la imagen
var current_index := 0

# Array con la textura (imagénes)
var textures: Array[Texture2D] = []

func _ready():
	# Asegurate de que el array no esta vacio
	if textures.size() == 0:
		push_error("No se cargaron las texturas!")
		
	# Controlar la visibilidad del botón
	if es_ultimo_nivel == false:
		CambiarObjeto.hide()
	else:
		CambiarObjeto.show()
	if textures.size() == 0:
		push_error("No se cargaron las texturas!")
		
	# Tu código anterior para mostrar/ocultar el botón de cambiar objeto...
	if es_ultimo_nivel == false:
		CambiarObjeto.hide()
	else:
		CambiarObjeto.show()
		
	# --- NUEVO: Actualizar el icono de ataque ---
	actualizar_icono_arma()


func actualizar_icono_arma() -> void:
	if GameManager:
		match GameManager.arma_equipada_actual:
			"cuchillo":
				boton_usar.texture_normal = icono_cuchillo
			"lanza":
				boton_usar.texture_normal = icono_lanza
			"escudo":
				boton_usar.texture_normal = icono_escudo
			"hacha":
				boton_usar.texture_normal = icono_hacha
			"flauta":
				boton_usar.texture_normal = icono_flauta
			"macuahuitle":
				boton_usar.texture_normal = icono_macuahuitle
