extends Node3D

#audioStream
@onready var music = $BackgroundPlayer

#music
var sound = preload("res://sounds/Copy of Opening Theme Demo 1.WAV")


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
