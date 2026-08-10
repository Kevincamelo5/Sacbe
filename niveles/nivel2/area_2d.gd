extends Area2D

# Referencia al nodo que contiene la interfaz del minijuego
@export var MInijuego: Control 

func _ready():
	# Conectamos la señal que detecta cuando algo entra al área
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Verificamos si lo que entró es el jugador (Quitzal)
	if body is Jugador:
		print("¡Altar activado!")
		activar_reto_matematico()

func activar_reto_matematico():
	if MInijuego:
		MInijuego.show() # Mostramos la pantalla de restas
		get_tree().paused = true 
		MInijuego.preparar_pregunta() # Llamamos a la función que genera la resta
