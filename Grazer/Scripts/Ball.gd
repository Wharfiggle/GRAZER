extends KinematicBody

# Declare member variables here. Examples:
var velocity = Vector3(0,0,0)
const GRAVITY = 30
const SPEED = 10
const JUMP = 15
var cow = preload("res://Assets/Cow.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Test") # Replace with function body.


#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print("frame")
	if(Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_left")):
		velocity.x = 0
	elif(Input.is_action_pressed("ui_right")):
		velocity.x = SPEED
	elif(Input.is_action_pressed("ui_left")):
		velocity.x = -SPEED
	else:
		velocity.x = lerp(velocity.x, 0, 0.1)
	
	if(Input.is_action_pressed("ui_down") and 
	Input.is_action_pressed("ui_up")):
		velocity.z = 0
	elif(Input.is_action_pressed("ui_down")):
		velocity.z = SPEED
	elif(Input.is_action_pressed("ui_up")):
		velocity.z = -SPEED
	else:
		velocity.z = lerp(velocity.z,0,0.1)

	if(transform.origin.y < -20.0):
		transform.origin = Vector3(0,6,0)

	if(Input.is_action_just_pressed("debug1")):
		var instance = cow.instance()
		get_parent().add_child(instance)

func _physics_process(delta):
	velocity.y -= GRAVITY * delta
	
	if(Input.is_action_just_pressed("jump") and is_on_floor()):
		velocity.y += JUMP
	elif(is_on_floor()):
		velocity.y = -0.1

	move_and_slide(velocity, Vector3.UP)

