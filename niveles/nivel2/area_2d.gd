extends Area2D

# Referencia al nodo que contiene la interfaz del minijuego
@export var MInijuego: Control 

func _ready():
	# Conectamos la señal que detecta cuando algo entra al área
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
# Este print nos dirá si el área funciona físicamente
	print("El altar detectó una colisión con: ", body.name) 
	
	# Usamos el grupo en lugar de 'is Jugador'
	if body.is_in_group("jugador"):
		print("¡Altar activado correctamente!")
		activar_reto_matematico()

func activar_reto_matematico():
	if MInijuego:
		MInijuego.show() # Mostramos la pantalla de restas
		get_tree().paused = true 
		MInijuego.preparar_pregunta() # Llamamos a la función que genera la resta
