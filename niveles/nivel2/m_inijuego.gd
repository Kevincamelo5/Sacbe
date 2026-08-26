extends Control

# Referencias a tus nodos de la interfaz
@onready var label_operacion = $Label
@onready var boton_a = $Button
@onready var boton_b = $Button2
@onready var boton_c = $Button3

# Referencias a las recompensas
@onready var contenedor_objetos = $ContenedorObjetos
@onready var boton_flauta = $ContenedorObjetos/BotonFlauta
@onready var boton_hacha = $ContenedorObjetos/BotonHacha
@onready var boton_lanza = $ContenedorObjetos/BotonLanza

var respuesta_correcta: int

# --- VARIABLES PARA CONTROLAR LAS RONDAS ---
var preguntas_resueltas: int = 0
var total_preguntas: int = 3

func _ready():
	hide()
	contenedor_objetos.hide() # Nos aseguramos que las armas empiecen ocultas
	
	# Conexión de los botones de recompensa
	boton_flauta.pressed.connect(func(): _seleccionar_objeto("flauta"))
	boton_hacha.pressed.connect(func(): _seleccionar_objeto("hacha"))
	boton_lanza.pressed.connect(func(): _seleccionar_objeto("lanza"))
	
	preparar_pregunta()

# Función para iniciar o reiniciar el minijuego desde cero
func iniciar_minijuego():
	preguntas_resueltas = 0 
	
	# Nos aseguramos de mostrar la interfaz de matemáticas y ocultar las armas
	label_operacion.show()
	boton_a.show()
	boton_b.show()
	boton_c.show()
	contenedor_objetos.hide()
	
	show()
	preparar_pregunta()

func preparar_pregunta():
	# 1. Generamos dos números aleatorios para la resta (Nivel 2)
	var num1 = randi_range(10, 20)
	var num2 = randi_range(1, num1) 
	
	respuesta_correcta = num1 - num2
	
	# 2. Mostramos la operación en el Label
	label_operacion.text = str(num1) + " - " + str(num2) + " = ?"
	
	# 3. Ponemos las opciones en los botones de forma aleatoria
	var opciones = [respuesta_correcta, respuesta_correcta + 2, respuesta_correcta - 1]
	opciones.shuffle() 
	
	boton_a.text = str(opciones[0])
	boton_b.text = str(opciones[1])
	boton_c.text = str(opciones[2])

# Función central de validación
func _on_respuesta_seleccionada(texto_boton: String):
	if int(texto_boton) == respuesta_correcta:
		print("¡Correcto!")
		preguntas_resueltas += 1 # Sumamos un acierto
		
		# Comprobamos si ya completó las 3 operaciones
		if preguntas_resueltas >= total_preguntas:
			print("¡Operaciones completadas! Mostrando recompensas...")
			_mostrar_recompensas()
		else:
			# Si aún faltan, preparamos la siguiente pregunta
			preparar_pregunta()
	else:
		print("Incorrecto, intenta de nuevo")

# Nueva función para cambiar la vista a las recompensas
func _mostrar_recompensas():
	# Ocultamos la UI de matemáticas
	label_operacion.hide()
	boton_a.hide()
	boton_b.hide()
	boton_c.hide()
	
	# Mostramos las armas
	contenedor_objetos.show()

# Nueva función que se llama cuando eligen un arma
# Nueva función adaptada al sistema de tu compañero
func _seleccionar_objeto(objeto_elegido: String):
	print("Quitzal ha obtenido: ", objeto_elegido)
	
	# 1. Desbloqueamos el arma en el GameManager de tu compañero
	if GameManager:
		GameManager.armasDesbloqueadas[objeto_elegido] = true
		print("Arma registrada en GameManager")
	
	# 2. Buscamos al jugador con el nombre de grupo correcto ("jugador")
	var jugador = get_tree().get_first_node_in_group("jugador")
	
	# 3. Equipamos el arma automáticamente forzando el cambio en el Enum
	if jugador:
		match objeto_elegido:
			"flauta":
				jugador.objetoActual = jugador.OBJETOS.FLAUTA
			"hacha":
				jugador.objetoActual = jugador.OBJETOS.HACHA # *Nota: Ver el punto 3 abajo
			"lanza":
				jugador.objetoActual = jugador.OBJETOS.LANZA
	
	_cerrar_minijuego()

func _cerrar_minijuego():
	self.hide()
	get_tree().paused = false # Reanudamos el movimiento de Quitzal

# --- CONEXIÓN DE LOS BOTONES DE MATEMÁTICAS ---
func _on_button_pressed() -> void:
	_on_respuesta_seleccionada(boton_a.text)

func _on_button_2_pressed() -> void:
	_on_respuesta_seleccionada(boton_b.text)

func _on_button_3_pressed() -> void:
	_on_respuesta_seleccionada(boton_c.text)


func _on_area_salida_body_entered(body):
	print("Alguien entro al area")
	if body.name == "Jugador":
		get_tree().change_scene_to_file(
			"res://mapa/nivel2/batalla_jabali.tscn"
		)
