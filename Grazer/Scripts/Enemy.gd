extends KinematicBody

export (NodePath) var targetNodePath = "../Ball"
export (float) var circleSpeed = 3
export (float) var lookSpeed = 1
export (float) var followDistance = 10
export (float) var radius = 30
export (float) var d = 0 #counter for _process
var target
var velocity = Vector3(0, 0, 0)

var currentMode = "Idle"
var marauderType #thief or gunman

# Called when the node enters the scene tree for the first time.
func _ready():
	target = get_node(targetNodePath)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#TODO call the respective path setting function depending on
	#what mode the marauder is in currently.
	
	
	d += delta
	
	var targetVector = Vector2(
		translation.x - target.global_translation.x,
		translation.z - target.global_translation.z)
	
	velocity.x = sin(d * circleSpeed) * radius
	velocity.z = cos(d * circleSpeed) * radius
	
	
	velocity.y -= 30 * delta
	if(is_on_floor()):
		velocity.y = -0.1
	move_and_slide(velocity, Vector3.UP)

func idle():
	#Marauder sits still, maybe makes occasional random movements
	print("Idle mode")
	

func pursuit():
	#Marauder runs directly at cowboy.
	#Once close enough,
	#If marauderType is gunman, they attempt to shoot the cowboy. 
	print("Pursuit mode")
	

func circle():
	#Marauder circles around the herd. If marauderType is theif, it should 
	#try to avoid the cowboy. If marauderType is gunman, it should(?) switch to pursuit
	#when the cowboy gets close.
	print("Circle mode")
	

func cowPursuit():
	#Marauder runs towards closest cow and attempts to lasso when in range
	#If successful, or cowboy gets too close, the marauder switches to flee mode.
	print("Cow pursuit mode")
	

func flee():
	#Marauder runs away from cowboy towards offscreen until it despawns.
	#If is currently lassoed to a cow, move speed is slowed.
	#If health gets too low, sever lasso and attempt to escape.
	print("Flee mode")
	
