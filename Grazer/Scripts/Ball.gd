extends KinematicBody

# Declare member variables here. Examples:
#export (PackedScene) var Bullet
var Bullet = preload("res://Prefabs/bullet.tscn")

onready var hitBox = $knockbox

var maxHitpoints = 10

var hitpoints = maxHitpoints
#export (PackedScene) var Smoke = null

var Smoke = preload("res://Prefabs/Smoke.tscn")

var velocity = Vector3(0,0,0)

var Dodge = Vector3(0,0,0)

const GRAVITY = 30
const SPEED = 9
const DODGESPEED = 12
const JUMP = 15
var herdPrefab = preload("res://Prefabs/Herd.tscn")
var herd

# Called when the node enters the scene tree for the first time.
#func _ready():

#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(herd == null):
		herd = herdPrefab.instance()
		get_node(NodePath("/root/Level")).add_child(herd)
		#get_node(NodePath("root/StaticBody")).add_child(herd)
		
	var toAdd = Vector3()
	if(!(Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_left"))):	
		if(Input.is_action_pressed("ui_right")):
			toAdd.x += 1
			toAdd.z += -1
		elif(Input.is_action_pressed("ui_left")):
			toAdd.x += -1
			toAdd.z += 1
	if(!(Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_up"))):
		if(Input.is_action_pressed("ui_down")):
			toAdd.x += 1
			toAdd.z += 1
		elif(Input.is_action_pressed("ui_up")):
			toAdd.x += -1
			toAdd.z += -1
	
	toAdd = toAdd.normalized() * SPEED
	if(toAdd.x == 0 and toAdd.z == 0):
		velocity.x = lerp(velocity.x,0,0.1)
		velocity.z = lerp(velocity.z,0,0.1)
		herd.canHuddle = true
	else:
		herd.clearHuddle()
		herd.canHuddle = false
		velocity.x = toAdd.x
		velocity.z = toAdd.z
	
	if(transform.origin.y < -20.0):
		transform.origin = Vector3(0,6,0)

	if(Input.is_action_just_pressed("debug1")):
		if(herd != null):
			herd.spawnCow()
		else:
			print("fuck there is no herd") #yeah
	
	if(Input.is_action_just_pressed("Follow Wait")):
		herd.toggleFollow()
	
	if(Input.is_action_just_pressed("dodge")):
		Dodge = toAdd.normalized() * DODGESPEED
		knock(toAdd, DODGESPEED)
		
	else:
		Dodge = Vector3(0, 0, 0)
		
		
	death()

func _physics_process(delta):
	velocity.y -= GRAVITY * delta
	
	if(Input.is_action_just_pressed("jump") and is_on_floor()):
		velocity.y += JUMP
	elif(is_on_floor()):
		velocity.y = -0.1

	move_and_slide(velocity + Dodge, Vector3.UP)
	
	if Input.is_action_just_pressed("shoot"):
			var b = Bullet.instance()
			owner.add_child(b)
			b.transform = $Position3D.global_transform
			b.velocity = b.transform.basis.z * b.muzzle_velocity
			print("BangBang")
			_emit_smoke(b)
	

func findHerdCenter() -> Vector3:
	return herd.findHerdCenter()

func _emit_smoke(bullet):
	var newSmoke = Smoke.instance()
	bullet.add_child(newSmoke)


func knock(direction, speed):
	var enemies = hitBox.get_overlapping_bodies()
	
	for enemy in enemies:
		if enemy.has_method("knockback"):
			enemy.knockback(direction, speed)
			
	


func damage_taken(damage):
	hitpoints -= damage
	
	if hitpoints <= 0:
		print("Wasted")

func death():
	if hitpoints <= 0:
		print("Wasted")




