extends Node2D

const ANIMAL = preload("res://scenes/animal/animal.tscn")
@onready var animal_start = $AnimalStart
const MAIN = preload("res://scenes/main/main.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_animal_died.connect(_on_animal_died)
	initAnimal()	

func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_packed(MAIN)
	
	
func _on_animal_died():
	initAnimal()
	
	
func initAnimal(): 
	var animal = ANIMAL.instantiate() 
	animal.position = animal_start.position
	add_child(animal)
