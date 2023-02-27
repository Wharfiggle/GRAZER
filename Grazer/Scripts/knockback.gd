extends KinematicBody
 ##This needs to be added to an enemy
var velocity = Vector3(0,0,0)

var gravity = 30
var speed = velocity
var knock = Vector3(0,0,0)
var lifespan = 10
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func knockback(push, zoom):
	speed = push * zoom
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	
	
	speed = speed.move_toward(velocity, 100 * delta)
	

	speed.y = speed.y - gravity*delta
	if is_on_floor():
		speed.y = -0.1
	
	speed = move_and_slide(speed)
	

	
