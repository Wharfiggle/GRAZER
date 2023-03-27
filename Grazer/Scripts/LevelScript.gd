extends Node3D

#audioStream
@onready var music = $BackgroundPlayer

#music
var testsound = preload("res://sounds/cowbellohyeah.wav")


# Called when the node enters the scene tree for the first time.
func _ready():
	#selecting sound to play
	music.stream = testsound
	#Starting sound
	#music.play()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
