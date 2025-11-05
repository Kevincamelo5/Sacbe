extends Node

#variable para indicar en que nivel se va a cambiar
var change_scene: String

#limites de busqueda entre los números variables.
var min_number: float = 1
var max_number: float = 100

#variable de enteros aleatorios
@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

#función generar números flotantes aleatorios
func in_random(min_number, max_number):
	rng.randomize()
	return rng.randf_range(min_number, max_number)

#funcion generar de números flotantes aleatorios
