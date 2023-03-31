extends Node3D

#audioStream
@onready var music = $BackgroundPlayer

#music
var sound = preload("res://sounds/Copy of Opening Theme Demo 1.WAV")

class Item:
	#icon textures
	var health1Tex = preload("res://Assets/Images/empress of bostonia.png")
	
	var id
	var description
	var icon
	var cost
	func _init(inId):
		id = inId
		if(id == "health1"):
			icon = health1Tex
			cost = 1
	func use():
		if(id == "health1"):
			print("heal a bit")

var items = [Item.new("health1")]

# Called when the node enters the scene tree for the first time.
func _ready():
	#selecting sound to play
	music.stream = sound
	#Starting sound
	music.play(5.37)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
