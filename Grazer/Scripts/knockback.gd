extends KinematicBody
 ##This needs to be added to an enemy
var velocity = Vector3()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func knockback(push):
	
	var speed = Vector3()
	var current_speed = speed
	speed -= push
	speed = current_speed
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
