class_name tileNode extends Node

#variables to hold references to neighboring tiles
var x
var z

var topLeft = null
var topRight = null
var botLeft = null
var botRight = null


# Called when the node enters the scene tree for the first time.
func _ready():
	x = self.transform.origin.x
	z = self.transform.origin.z

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
