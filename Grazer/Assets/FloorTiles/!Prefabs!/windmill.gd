extends Node3D

@onready var wind = $AudioPlayer

#var creck1 = preload("res://sounds/newSounds/windmill/windmill1.wav")
var creck2 = preload("res://sounds/newSounds/windmill/windmill2.wav")
var creck3 = preload("res://sounds/newSounds/windmill/windmill3.wav")

var windarray = [creck2,creck3]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(!wind.playing):
		wind.stream = windarray[randi_range(0, windarray.size() - 1)]
	
