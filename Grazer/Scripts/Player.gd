extends CharacterBody3D

# Declare member variables here. Examples:
var bullet = preload("res://Prefabs/Bullet.tscn")
var smoke = preload("res://Prefabs/Smoke.tscn")
@export var shootTime = 0.2
var shootTimer = 0.0
@export var shootBufferTime = 0.1
var shootBufferTimer = 0.0
@onready var knockbox = $knockbox
var maxHitpoints = 10.0
var hitpoints = maxHitpoints
var Smoke = preload("res://Prefabs/Smoke.tscn")
var tVelocity = Vector3(0,0,0)
@export var dodgeSpeed = 15.0
var dodgeVel = Vector3(0,0,0)
@export var dodgeTime = 0.5
var dodgeTimer = 0.0
@export var dodgeCooldownTime = 0.3
var dodgeCooldownTimer = 0.0
@export var dodgeBufferTime = 0.1
var dodgeBufferTimer = 0.0
var dodging = false
var knocked = false
@onready var healthCounter = get_node(NodePath("/root/Level/Health Counter"))
#audioStreams
@onready var Steps = $footsteps
@onready var Vocal = $Voice
#preloading sound file
var run = preload("res://sounds/Foley files/Foley files (Raw)/Shoe Fast#02.wav")
var GSSound = preload("res://sounds/gunsounds/Copy of revolverfire.wav")
var critSound = preload("res://sounds/gunsounds/crit shot.wav")

#revolver capacity, revolver damage, revolver reload, shotgun capacity, shotgun damage, shotgun reload
@export var gunStats = [0, 0, 0, 0, 0, 0]
@export var potionTime = 30.0
var potionTimer = 0.0
var potion
var lifeLeach = 0.0
var potionSpeedup = 1.0
var alwaysCrit = false
var critChance = 0.1

const GRAVITY = 30
@export var speed = 8.0
const JUMP = 15
var herdPrefab = preload("res://Prefabs/Herd.tscn")
var herd
@onready var camera = get_node(NodePath("/root/Level/Camera3D"))
var moveDir = 0.0
var aimDir = 0.0
var aimSwivel = 0.0
@export var revolverPath:NodePath
@onready var revolver = get_node(revolverPath)
#@export var shotgunPath:NodePath
#var shotgun
@export var revolverRange = 18.0
@export var shotgunRange = 4.0
@onready var shootingPoint = revolver.find_child("ShootingPoint")
@onready var lineSightRaycast = shootingPoint.get_child(0)
@onready var lineSightMesh = preload("res://Prefabs/BulletTrailMesh.tres")
var lineSight
var onRevolver = true
var active = true

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	healthCounter.updateHealth(hitpoints)
	lineSight = lineSightMesh.duplicate()
	lineSightRaycast.get_child(0).mesh = lineSight
	lineSightRaycast.target_position = Vector3(0, 0, revolverRange)

#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(herd == null):
		herd = herdPrefab.instantiate()
		get_node(NodePath("/root/Level")).add_child(herd)
		herd.spawnCowAtPos(Vector3(position.x, position.y, position.z - 2))
		#herd.spawnCowAtPos(Vector3(position.x - 1, position.y, position.z - 3))
		
	if(herd.getNumCows() < 1):
		die()
	
	if(shootTimer > 0):
		shootTimer -= delta
		if(shootTimer < 0):
			shootTimer = 0
	if(shootBufferTimer > 0):
		shootBufferTimer -= delta
		if(shootBufferTimer < 0):
			shootBufferTimer = 0
			
	if(potionTimer > 0):
		potionTimer -= delta
		if(potionTimer < 0):
			potionTimer = 0
			potion.use(false)
			potion = null
		
	if(Input.is_action_just_pressed("shoot") && dodgeTimer == 0):
		shootBufferTimer = shootBufferTime
	if(active && shootBufferTimer > 0 && shootTimer == 0):
		Input.start_joy_vibration(0,1,1,0.07)
		var smokeInstance = smoke.instantiate()
		shootingPoint.add_child(smokeInstance)
		smokeInstance.position = Vector3.ZERO
		smokeInstance.get_child(0).emitting = true
		smokeInstance.get_child(1).emitting = true
		var critMult = 1.0
		if(alwaysCrit || randf_range(0, 1) <= critChance):
			critMult = 2.0
			#crit particle
			#smokeInstance.get_child(2).emitting = true
		var boomSound = smokeInstance.find_child("Boom")
		if(onRevolver):
			var b = bullet.instantiate()
			b.shoot(self, "player", shootingPoint.global_position, Vector3(0, aimDir, 0), revolverRange, 2.0 * critMult)
			if(!critMult == 2.0):
				boomSound.stream = GSSound
				boomSound.play(.55)
			else:
				boomSound.stream = critSound
				boomSound.play()
		else:
			print("shotgun shoot")
		shootTimer = shootTime
	
	#setting sound 
	Steps.stream = run
	var toAdd = Vector3()
	if(!(Input.is_action_pressed("moveRight") and Input.is_action_pressed("moveLeft"))):
		if(Input.is_action_pressed("moveRight")):
			toAdd.x += 1
			toAdd.z += -1
		elif(Input.is_action_pressed("moveLeft")):
			toAdd.x += -1
			toAdd.z += 1
	if(!(Input.is_action_pressed("moveDown") and Input.is_action_pressed("moveUp"))):
		if(Input.is_action_pressed("moveDown")):
			toAdd.x += 1
			toAdd.z += 1
		elif(Input.is_action_pressed("moveUp")):
			toAdd.x += -1
			toAdd.z += -1
	var stickToAdd = Vector3(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), 0, Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
	stickToAdd = Vector3(cos(-PI/4.0) * stickToAdd.x - sin(-PI/4.0) * stickToAdd.z, 0,
		sin(-PI/4.0) * stickToAdd.x + cos(-PI/4.0) * stickToAdd.z)
	if(stickToAdd.length() >= 0.3):
		toAdd = stickToAdd
	if(toAdd != Vector3.ZERO):
		moveDir = atan2(toAdd.x, toAdd.z)
	#rotate towards where player is moving
	if(active):
		rotation.y = lerp_angle(
			rotation.y,
			moveDir,
			0.1)
	
	toAdd = toAdd.normalized() * speed * potionSpeedup
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
	
	if(Input.is_action_just_pressed("Follow Wait") && active):
		herd.toggleFollow()
	
	#player looks where mouse is pointed but projected to isometric view
	if(camera != null && active):
		var prevAimDir = aimDir
		var viewport = get_viewport()
		var mousePos = viewport.get_mouse_position()
		var rightStick = Vector3(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), 0, Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
		#get aimDir based on right stick
		if(rightStick.length() > 0.3):
			aimDir = -atan2(rightStick.z, rightStick.x) - PI * 5.0 / 4.0
		#get aimDir based on mouse movement
		else:
			#old method involving raycasts. expensive and collided with non-ground objects
				#var ray_length = 100
				#var from = camera.project_ray_origin(mousePos)
				#var to = from + camera.project_ray_normal(mousePos) * ray_length
				#var space = get_world_3d().direct_space_state
				#var ray_query = PhysicsRayQueryParameters3D.new()
				#ray_query.from = from
				#ray_query.to = to
				#ray_query.collide_with_areas = true
				#var aimAt = space.intersect_ray(ray_query).get("position", Vector3(0, 0, 0))
				#angle from the camera plane to the ground plane
			var camAngle = camera.rotation.x
			if(camAngle < 0):
				camAngle = PI/2.0 + fmod(camAngle, PI/2.0)
			else:
				camAngle = fmod(camAngle, PI/2.0)
			#used to make the aimAt position on the ground plane compensate
			#for the difference in angle to the camera plane
			var angMod = 1.0 / cos(camAngle)
			var viewWid = viewport.get_visible_rect().size.x #viewport width in pixels
			var viewHei = viewport.get_visible_rect().size.y #viewport height in pixels
			var unitHei = camera.size #equal to the number of units that fit in the camera's height
			var mouseOffset = mousePos
			mouseOffset -= Vector2(viewWid / 2.0, viewHei / 2.0) #center cursor
			#a little arbitrary but makes cursor and aimAt line up good enough on the y-axis
			mouseOffset.y -= (camera.camOffset.y - camera.camOffset.x) / unitHei * viewHei - unitHei
			#rotate to compensate for isometric 45 degree angle
			var aimAt = Vector3(
				cos(-PI/4.0) * mouseOffset.x - sin(-PI/4.0) * mouseOffset.y * angMod, 0,
				sin(-PI/4.0) * mouseOffset.x + cos(-PI/4.0) * mouseOffset.y * angMod)
			aimAt *= unitHei / viewHei #convert from pixels to units
			aimAt.y = 1.0
			aimAt += camera.global_position - camera.camOffset #offset to position camera is aiming at
#			var worldCursor = get_node(NodePath("WorldCursor"))
#			if(worldCursor != null):
#				worldCursor.global_position = aimAt
			aimDir = atan2(position.x - aimAt.x, position.z - aimAt.z) + PI
		if(aimDir != prevAimDir):
			revolver.rotation.y = aimDir - rotation.y
			#0 - 0.5 is right hand, 0.5 - 1.0 is left hand
			aimSwivel = fmod(aimDir - rotation.y + PI, 2 * PI) / (2 * PI)
	else:
		camera = get_node(NodePath("/root/Level/Camera3D"))


func _physics_process(delta):
	#line of sight
	if(lineSightRaycast.is_colliding()):
		var dist = (lineSightRaycast.get_collision_point() - lineSightRaycast.global_position).length()
		lineSight.updateTrail([Vector3.ZERO, Vector3(0, 0, dist)])
	else:
		lineSight.updateTrail([Vector3.ZERO, Vector3(0, 0, revolverRange)])
	
	tVelocity.y -= GRAVITY * delta
	if(Input.is_action_just_pressed("jump") and is_on_floor()):
		tVelocity.y += JUMP
	elif(is_on_floor()):
		tVelocity.y = -0.1

	set_velocity(tVelocity)
	if(dodgeVel != Vector3.ZERO):
		set_velocity(Vector3(dodgeVel.x, tVelocity.y, dodgeVel.z))
	set_up_direction(Vector3.UP)
	if(active):
		move_and_slide()
	
	if(Input.is_action_just_pressed("dodge")):
		dodgeBufferTimer = dodgeBufferTime
	elif(dodgeBufferTimer > 0):
		dodgeBufferTimer -= delta
		if(dodgeBufferTimer < 0):
			dodgeBufferTimer = 0
			dodging = true
	
	if(active && dodgeBufferTimer > 0 && dodgeCooldownTimer == 0):
		Input.start_joy_vibration(0,0.6,0.6,.1)
		dodgeCooldownTimer = dodgeCooldownTime
		dodgeTimer = dodgeTime
		dodgeVel = Vector3(sin(moveDir), 0, cos(moveDir)) * dodgeSpeed
	if(dodgeTimer > 0):
		dodgeTimer -= delta
		if(dodgeTimer < 0):
			dodgeTimer = 0
			dodging = false
			knocked = false
			dodgeVel = Vector3.ZERO
			tVelocity = Vector3.ZERO
		else:
			var t = dodgeTimer / dodgeTime
			t = sqrt(t)
			var knockMod = 1.0
			if(knocked):
				knockMod = 0.1
			dodgeVel = Vector3(sin(moveDir), 0, cos(moveDir)) * dodgeSpeed * t * knockMod
		knock()
	elif(dodgeCooldownTimer > 0):
		dodgeCooldownTimer -= delta
		if(dodgeCooldownTimer < 0):
			dodgeCooldownTimer = 0 
			


func findHerdCenter() -> Vector3:
	return herd.findHerdCenter()

func knock():
	var enemies = knockbox.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.has_method("knockback"):
			enemy.knockback(enemy.position - Vector3(sin(moveDir), 0, cos(moveDir)), dodgeVel.length(), true)
			knocked = true

func damage_taken(damage, from) -> bool:
	if(from != "player"):
		print("player damaged")
		hitpoints -= damage
		healthCounter.updateHealth(hitpoints)
		if hitpoints <= 0:
			die()
		return true
	else:
		return false
		
func healFromBullet(damageDone):
	hitpoints += damageDone * lifeLeach
	if(hitpoints >= maxHitpoints):
		hitpoints = maxHitpoints
		
func die():
	active = false
	rotation.x = PI / 2.0
