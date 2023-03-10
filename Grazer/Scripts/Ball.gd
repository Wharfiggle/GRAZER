extends CharacterBody3D

# Declare member variables here. Examples:
#export (PackedScene) var Bullet
var Bullet = preload("res://Prefabs/bullet.tscn")
@onready var hitBox = $knockbox
var maxHitpoints = 10
var hitpoints = maxHitpoints
#export (PackedScene) var Smoke = null
var Smoke = preload("res://Prefabs/Smoke.tscn")
var tVelocity = Vector3(0,0,0)
var Dodge = Vector3(0,0,0)
@onready var sound = $"practice sound item/AudioStreamPlayer3D"
const GRAVITY = 30
const SPEED = 9
const DODGESPEED = 120
const JUMP = 15
var herdPrefab = preload("res://Prefabs/Herd.tscn")
var herd
var aimDir = 0
var force = 2
@onready var camera = get_node(NodePath("/root/Level/Camera3D"))

# Called when the node enters the scene tree for the first time.
#func _ready():

#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(herd == null):
		herd = herdPrefab.instantiate()
		get_node(NodePath("/root/Level")).add_child(herd)
		#get_node(NodePath("root/StaticBody3D")).add_child(herd)
	
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
		tVelocity.x = lerp(tVelocity.x,0.0,0.1)
		tVelocity.z = lerp(tVelocity.z,0.0,0.1)
		herd.canHuddle = true
	else:
		herd.clearHuddle()
		herd.canHuddle = false
		tVelocity.x = toAdd.x
		tVelocity.z = toAdd.z
	
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
		knock(Dodge, force)
		
	else:
		Dodge = Vector3(0, 0, 0)
		
	#player looks where mouse is pointed but projected to isometric view
	if(camera != null):
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_length = 100
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * ray_length
		var space = get_world_3d().direct_space_state
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = from
		ray_query.to = to
		ray_query.collide_with_areas = true
		var aimAt = space.intersect_ray(ray_query).get("position", Vector3(0, 0, 0))
		print("mouse_pos: " + str(mouse_pos) + " aimAt: " + str(position - aimAt))
		rotation.y = lerp_angle(
			rotation.y,
			atan2(position.x - aimAt.x, position.z - aimAt.z) + PI,
			0.3)
	else:
		camera = get_node(NodePath("/root/Level/Camera3D"))
		


func _physics_process(delta):
	tVelocity.y -= GRAVITY * delta
	
	if(Input.is_action_just_pressed("jump") and is_on_floor()):
		tVelocity.y += JUMP
	elif(is_on_floor()):
		tVelocity.y = -0.1

	set_velocity(tVelocity + Dodge)
	set_up_direction(Vector3.UP)
	move_and_slide()
	
	if Input.is_action_just_pressed("shoot"):
			var b = Bullet.instantiate()
			owner.add_child(b)
			b.transform = $Marker3D.global_transform
			b.velocity = b.transform.basis.z * b.muzzle_velocity
			print("BangBang")
			sound.play()
			_emit_smoke(b)
	

func findHerdCenter() -> Vector3:
	return herd.findHerdCenter()

func _emit_smoke(bullet):
	var newSmoke = Smoke.instantiate()
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




