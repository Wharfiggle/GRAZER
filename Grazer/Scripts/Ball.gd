extends KinematicBody

# Declare member variables here. Examples:
#export (PackedScene) var Bullet
var Bullet = preload("res://Prefabs/Bullet.tscn")

#export (PackedScene) var Smoke = null

var Smoke = preload("res://Prefabs/Smoke.tscn")

var velocity = Vector3(0,0,0)

var Dodge = Vector3(0,0,0)

const GRAVITY = 30
const SPEED = 10
const JUMP = 15
var cow = preload("res://Prefabs/Cow.tscn")
export (NodePath) var cowCounter = "/root/Level/Cow Counter"
var follow = true

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
		var instance = cow.instance()
		instance.transform.origin = findHerdCenter()
		instance.add_to_group("Herd")
		get_parent().add_child(instance)
		get_node(cowCounter).cows += 1
		
	if(Input.is_action_just_pressed("debug2")):
		follow = !follow
	
	if(Input.is_action_just_pressed("dodge") and Input.is_action_pressed("ui_left")):
		toAdd.x += -3
		toAdd.z += 3
	
	if(Input.is_action_just_pressed("dodge") and Input.is_action_pressed("ui_right")):
		toAdd.x += 3
		toAdd.z += -3
	
	if(Input.is_action_just_pressed("dodge") and Input.is_action_pressed("ui_up")):
		toAdd.x += -3
		toAdd.z += -3
	
	if(Input.is_action_just_pressed("dodge") and Input.is_action_pressed("ui_down")):
		toAdd.x += 3
		toAdd.z += 3
		
	Dodge.x = toAdd.x
	Dodge.z = toAdd.z
	
	
	





func _physics_process(delta):
	velocity.y -= GRAVITY * delta
	
	if(Input.is_action_just_pressed("jump") and is_on_floor()):
		velocity.y += JUMP
	elif(is_on_floor()):
		velocity.y = -0.1

	move_and_slide(velocity+Dodge, Vector3.UP)
	
	if Input.is_action_just_pressed("shoot"):
			var b = Bullet.instance()
			owner.add_child(b)
			b.transform = $Position3D.global_transform
			b.velocity = b.transform.basis.z * b.muzzle_velocity
			print("BangBang")
			_emit_smoke(b)

func findHerdCenter() -> Vector3:
	var herd = get_tree().get_nodes_in_group("herd")
	var loc = Vector3(0,0,0)
	var numCows = 0
	for x in herd:
		numCows += 1
		loc += x.transform.origin
	if(numCows > 0):
		loc /= numCows
	else:
		loc = Vector3(0, 10, 0)
	print("numCows: " + str(numCows))
	print(str(loc))
	return loc

func _emit_smoke(bullet):
	var newSmoke = Smoke.instance()
	bullet.add_child(newSmoke)

	
	
