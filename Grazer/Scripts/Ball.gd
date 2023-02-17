extends KinematicBody

# Declare member variables here. Examples:
export (PackedScene) var Bullet
var velocity = Vector3(0,0,0)
const GRAVITY = 30
const SPEED = 10
const JUMP = 15
var cow = preload("res://Prefabs/Cow.tscn")
export (NodePath) var cowCounter = "/root/Level/Cow Counter"

# Called when the node enters the scene tree for the first time.
#func _ready():
	
	


#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print("frame")
	var toAdd = Vector3()
	if(Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_left")):
		toAdd.x += 0
		toAdd.z += 0
	elif(Input.is_action_pressed("ui_right")):
		toAdd.x += 1
		toAdd.z += -1
	elif(Input.is_action_pressed("ui_left")):
		toAdd.x += -1
		toAdd.z += 1
	
	if(Input.is_action_pressed("ui_down") and 
	Input.is_action_pressed("ui_up")):
		toAdd.x += 0
		toAdd.z += 0
	elif(Input.is_action_pressed("ui_down")):
		toAdd.x += 1
		toAdd.z += 1
	elif(Input.is_action_pressed("ui_up")):
		toAdd.x += -1
		toAdd.z += -1
	
	toAdd = toAdd.normalized() * SPEED
	if(toAdd.x == 0 and toAdd.z == 0):
		velocity.x = lerp(velocity.x,0,0.1)
		velocity.z = lerp(velocity.z,0,0.1)
	else:
		velocity.x = toAdd.x
		velocity.z = toAdd.z
	
	if(transform.origin.y < -20.0):
		transform.origin = Vector3(0,6,0)

	if(Input.is_action_just_pressed("debug1")):
		findHerdCenter()
		var instance = cow.instance()
		instance.transform.origin = Vector3(0,10,0)
		instance.add_to_group("herd")
		get_parent().add_child(instance)
		get_node(cowCounter).cows += 1
		findHerdCenter()
	
	

func _physics_process(delta):
	velocity.y -= GRAVITY * delta
	
	if(Input.is_action_just_pressed("jump") and is_on_floor()):
		velocity.y += JUMP
	elif(is_on_floor()):
		velocity.y = -0.1

	move_and_slide(velocity, Vector3.UP)
	
	if Input.is_action_just_pressed("shoot"):
			var b =Bullet.instance()

func findHerdCenter() -> Vector3:
	var herd = get_tree().get_nodes_in_group("herd")
	var loc = Vector3(0,0,0)
	var numCows = 0
	for x in herd:
		numCows += 1
		loc += x.transform.origin
	loc /= numCows
	print("numCows: " + str(numCows))
	print(str(loc))
	return loc
