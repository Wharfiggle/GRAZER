extends CharacterBody3D

# Declare member variables here. Examples:
var bullet = preload("res://Prefabs/Bullet.tscn")
var smoke = preload("res://Prefabs/Smoke.tscn")
@export var revolverShootTime = 0.23
@export var shotgunShootTime = 0.3
var shootTime = revolverShootTime
var shootTimer = 0.0
@export var shootBufferTime = 0.1
var shootBufferTimer = 0.0
@onready var HealthBar = $"../GameUI"
@onready var knockbox = $knockbox
var maxHitpoints = 20.0
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
var movementBlend = 0.0

#Reload variables
var revolverReloadTime = 1
var shotgunReloadTime = 1.5
var currentReloadTime = 0
var revolverClipSize = 6
var revolverClip = 6
var shotgunClipSize = 2
var shotgunClip = 2
var idleTime = 0
var autoReloadEnabled = true
var autoReloadTime = 5
var reloading = false
var invincible = false

@onready var healthCounter = get_node(NodePath("/root/Level/Health Counter"))
#audioStreams
@onready var Steps = $footsteps
@onready var Vocal = $Voice
#preloading sound file
var runSound = preload("res://sounds/Foley files/Foley files (Raw)/Shoe Fast#02.wav")
var revolverShootSound = preload("res://sounds/gunsounds/Copy of revolverfire.wav")
var revolverCritSound = preload("res://sounds/gunsounds/crit shot.wav")
var shotgunShootSound = preload("res://sounds/gunsounds/Copy of revolverfire.wav")
var shotgunCritSound = preload("res://sounds/gunsounds/crit shot.wav")

#revolver capacity, revolver damage, revolver reload, shotgun capacity, shotgun damage, shotgun reload
@export var gunStats = [0, 0.0, 0.0, 0, 0.0, 0.0] #[6, 3.0, 1.0, 2, 0.5, 0.8]
@export var potionTime = 30.0
var potionTimer = 0.0
var potion
var lifeLeach = 0.0
var potionSpeedup = 1.0
var alwaysCrit = false
var critChance = 0.1

const GRAVITY = 30
@export var speed = 8.0
var herdPrefab = preload("res://Prefabs/Herd.tscn")
var herd
@onready var camera = get_node(NodePath("/root/Level/Camera3D"))
var moveDir = 0.0
var prevAimDir = [0, 0, 0, 0, 0]
var aimDir = 0.0
var aimSwivel = 0.0
@export var swivelSpeed = 0.2
@onready var gunRight = get_node(NodePath("./Russel/Armature/Skeleton3D/GunRight"))
@onready var gunLeft = get_node(NodePath("./Russel/Armature/Skeleton3D/GunLeft"))
var rightHand = true
var onRevolver = true
@export var shotgunRandOffset = 0.1
@export var revolverRange = 25.0
@export var shotgunRange = 5.0
@export var revolverDamage = 3.0
@export var shotgunDamage = 0.5
@export var shotgunSpread = 45.0
@export var shotgunBullets = 20
@onready var shootingPoint = gunRight.get_child(0).find_child("ShootingPoint")
@onready var lineSightRaycast = shootingPoint.get_child(0)
@onready var lineSightMesh = preload("res://Prefabs/BulletTrailMesh.tres")
@onready var lineSightNode = get_node("./LineOfSight")
@export var lineSightTransparency = 0.5
@export var lineSightTime = 0.8
var lineSightTimer = 0.0
var lineSight
@onready var animation = get_node(NodePath("./Russel/AnimationPlayer/AnimationTree"))
@onready var skeleton = get_node(NodePath("./Russel/Armature/Skeleton3D"))
@onready var worldCursor = get_node(NodePath("./WorldCursor"))
var mousePos = Vector2.ZERO
var cursorPos = Vector3.ZERO
var rng = RandomNumberGenerator.new()
var swapInputFrames = 5
var swapInputFrameCounter = 0
var active = true

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group('Player')
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	healthCounter.updateHealth(hitpoints)
	lineSight = lineSightMesh.duplicate()
	lineSightNode.mesh = lineSight
	lineSightRaycast.target_position = Vector3(0, 0, revolverRange)
	shotgunSpread = shotgunSpread * PI / 180.0
	lineSightNode.transparency = lineSightTransparency
	
	gunStats[0] = revolverClip
	gunStats[1] = revolverDamage
	gunStats[2] = revolverReloadTime
	gunStats[3] = shotgunClip
	gunStats[4] = shotgunDamage
	gunStats[5] = shotgunReloadTime
	
	#HealthBar._on_max_health_update_(10)

	#var phys_bones = ["Hips", "Spine", "Spine 1", "Spine2", "Neck", "LeftShoulder", "LeftArm", "leftForeArm", "LeftHand", "RightShoulder", "RightArm", "RightForeArm", "RightUpLeg", "LeftFoot", "RightFoot"]
	#skeleton.physical_bones_start_simulation(phys_bones)

#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(herd == null):
		herd = herdPrefab.instantiate()
		get_node(NodePath("/root/Level")).add_child(herd)
		herd.spawnCowAtPos(Vector3(position.x, position.y, position.z - 2))
		#herd.spawnCowAtPos(Vector3(position.x - 1, position.y, position.z - 3))
		
	if(herd.getNumCows() < 1 and !invincible):
		die()
	
	if(lineSightTimer > 0):
		lineSightTimer -= delta
		if(lineSightTimer < 0):
			lineSightTimer = 0
		if(onRevolver):
			lineSightNode.transparency = sqrt(sqrt(lineSightTimer / lineSightTime)) * (1.0 - lineSightTransparency) + lineSightTransparency
			
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
	
	#Temp var to allow easier comparisions
	var equippedClip
	var equippedClipSize
	if(onRevolver):
		equippedClip = revolverClip
		equippedClipSize = revolverClipSize
	else:
		equippedClip = shotgunClip
		equippedClipSize = shotgunClipSize
	
	if(Input.is_action_just_pressed("reload") and equippedClip < equippedClipSize):
		startReload()
	
	#Idle auto-reload timer, makes sure equipped gun is not fully loaded
	if(autoReloadEnabled and !reloading and equippedClip < equippedClipSize):
		idleTime += delta
		if(idleTime > autoReloadTime):
			startReload()
	
	#Reload timer countdown
	if(reloading):
		currentReloadTime -= delta
	#Finish reloading
	if(currentReloadTime <= 0 and reloading):
		finishReloading()
	#todo cancel reload if switching weapons
	
	#shoot gun input buffer
	if(Input.is_action_just_pressed("shoot") && dodgeTimer == 0):
		shootBufferTimer = shootBufferTime
	

	
	if(equippedClip <= 0 and !reloading):
		startReload()
	
	#shoot gun
	if(active && shootBufferTimer > 0 && shootTimer == 0 && equippedClip > 0):
		#If currently reloading, cancel reload
		if(reloading):
			currentReloadTime = 0
			reloading = false
		idleTime = 0
		
		Input.start_joy_vibration(0,1,1,0.07)
		var smokeInstance = smoke.instantiate()
		add_child(smokeInstance)
		smokeInstance.global_position = shootingPoint.global_position
		smokeInstance.get_child(0).emitting = true
		smokeInstance.get_child(1).emitting = true
		var critMult = 1.0
		rng.randomize()
		if(alwaysCrit || rng.randf_range(0, 1) <= critChance):
			critMult = 2.0
			#crit particle
			smokeInstance.get_child(2).emitting = true
		var boomSound = smokeInstance.find_child("Boom")
		#Shooting the revolver
		if(onRevolver):
			revolverClip -= 1
			var b = bullet.instantiate()
			b.shoot(self, "player", shootingPoint.global_position, Vector3(0, aimDir, 0), revolverRange, revolverDamage * critMult)
			if(!critMult == 2.0):
				boomSound.stream = revolverShootSound
				boomSound.play(.55)
			else:
				boomSound.stream = revolverCritSound
				boomSound.play()
		#Shooting the shotgun
		else:
			shotgunClip -= 1
			rng.randomize()
			var bullets = 0
			while bullets < shotgunBullets:
				var b = bullet.instantiate()
				var rnSpread = rng.randf_range(-shotgunRandOffset, shotgunRandOffset)
				var rnRange = shotgunRange + rng.randf_range(-shotgunRange * shotgunRandOffset, shotgunRange * shotgunRandOffset)
				var bRotation = Vector3(0, aimDir - shotgunSpread / 2.0
					+ (shotgunSpread / (shotgunBullets - 1)) * bullets + rnSpread, 0)
				b.shoot(self, "player", shootingPoint.global_position, bRotation, rnRange, shotgunDamage * critMult, 50.0)
				bullets += 1
			if(!critMult == 2.0):
				boomSound.stream = revolverShootSound
				boomSound.play(.55)
			else:
				boomSound.stream = revolverCritSound
				boomSound.play()
		shootTimer = shootTime
		lineSightTimer = lineSightTime
	
	#setting sound 
	Steps.stream = runSound
	
	#movement
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
	#stick input rotated 45 degrees to match isometric
	stickToAdd = Vector3(cos(-PI/4.0) * stickToAdd.x - sin(-PI/4.0) * stickToAdd.z, 0,
		sin(-PI/4.0) * stickToAdd.x + cos(-PI/4.0) * stickToAdd.z)
	stickToAdd *= 1.0 / max(0.8, stickToAdd.length()) #treat magnitude of 0.8 as the max
	if(stickToAdd.length() >= 0.3):
		toAdd = stickToAdd
		worldCursor.visible = false
	elif(toAdd.length() > 0):
		toAdd = toAdd.normalized()
		worldCursor.visible = true
	#adjust walking animation speed to match speed
	movementBlend = lerpf(movementBlend, toAdd.length(), 0.1)
	animation.set("parameters/idleWalk/blend_amount", movementBlend)
	if(toAdd != Vector3.ZERO):
		moveDir = atan2(toAdd.x, toAdd.z)
#	else:
#		animation.set("parameters/idleWalk/blend_amount", 0.0)
	#rotate towards where player is moving
	if(active):
		rotation.y = lerp_angle(
			rotation.y,
			moveDir,
			0.1)
	lineSightNode.global_position = shootingPoint.global_position
	lineSightNode.global_rotation = Vector3(0, aimDir, 0)
	
	toAdd = toAdd * speed * potionSpeedup
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
		
	#update world cursor position
	worldCursor.global_position = position + cursorPos

	if(Input.is_action_just_pressed("debug1")):
		if(herd != null):
			herd.spawnCow()
		else:
			print("fuck there is no herd") #yeah
	
	if(Input.is_action_just_pressed("Follow Wait") && active):
		herd.toggleFollow()

func startReload():
	print("Reloading")
	reloading = true
	if(onRevolver):
		currentReloadTime = revolverReloadTime
	else:
		currentReloadTime = shotgunReloadTime
	idleTime = 0

func finishReloading():
	print("Finished Reloading")
	reloading = false
	idleTime = 0
	if(onRevolver):
		revolverClip = revolverClipSize
	else:
		shotgunClip = shotgunClipSize

func _physics_process(delta):
	#swap weapon
	if(active):
		var swapInput = 0
		if(Input.is_action_just_released("SwapWeapon")): swapInput = 1
		elif(Input.is_action_just_released("SwapWeaponDown")): swapInput = -1
		if( (swapInputFrameCounter == 0 && swapInput != 0) 
		|| (swapInput > 0 && swapInputFrameCounter < 0) 
		|| (swapInput < 0 && swapInputFrameCounter > 0) ):
			setWeapon(!onRevolver)
			swapInputFrameCounter = swapInputFrames * swapInput
		elif(swapInputFrameCounter != 0 && swapInput == 0):
			swapInputFrameCounter -= swapInputFrameCounter / abs(swapInputFrameCounter)
	
	#line of sight
	if(lineSightRaycast.is_colliding()):
		var dist = (lineSightRaycast.get_collision_point() - lineSightRaycast.global_position).length()
		lineSight.updateTrail([Vector3.ZERO, Vector3(0, 0, dist)])
	else:
		lineSight.updateTrail([Vector3.ZERO, Vector3(0, 0, revolverRange)])
	
	#player looks where mouse is pointed but projected to isometric view
	if(camera != null && active):
		var viewport = get_viewport()
		var prevMousePos = mousePos
		mousePos = viewport.get_mouse_position()
		var rightStick = Vector3(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), 0, Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
		var leftStick = Vector3(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), 0, Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
		#get aimDir based on right stick
		if(rightStick.length() > 0.6):
			aimDir = -atan2(rightStick.z, rightStick.x) - PI * 5.0 / 4.0
			worldCursor.visible = false
		elif(leftStick.length() > 0.3):
			print("asdasdasd")
			aimDir = -atan2(leftStick.z, leftStick.x) - PI * 5.0 / 4.0
			worldCursor.visible = false
		#get aimDir based on mouse movement
		elif(prevMousePos != mousePos || worldCursor.visible):
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
			aimAt.y = 1.5
			aimAt += camera.global_position - camera.camOffset #offset to position camera is aiming at
			worldCursor.visible = true
			cursorPos = aimAt - position
			aimDir = atan2(position.x - aimAt.x, position.z - aimAt.z) + PI
		#bring aimDir to 0 - 2PI
		aimDir = fmod(aimDir, 2 * PI)
		if(aimDir < 0):
			aimDir = 2 * PI + aimDir
		var realAimDir = aimDir
		#account for crossover from 0 to 2PI or vice versa
		var aimDelta = aimDir - prevAimDir[0]
		if(abs(aimDelta) >= PI):
			var mod = aimDelta / abs(aimDelta)
			for i in prevAimDir.size():
				prevAimDir[i] += PI * 2.0 * mod
		#get average aimDir
		for i in prevAimDir.size():
			aimDir += prevAimDir[i]
		aimDir /= prevAimDir.size() + 1
		#remove oldest frame and add current frame's aimDir
		prevAimDir.push_front(realAimDir)
		prevAimDir.pop_back()
		
		#-1 - 0 is left hand, 0 - 1.0 is right hand
		var prevAimSwivel = aimSwivel
		aimSwivel = fmod(2 * PI + aimDir - rotation.y + PI, 2 * PI) / (2 * PI)
		aimSwivel = -(aimSwivel * 2 - 1)
		aimSwivel = lerpf(prevAimSwivel, aimSwivel, swivelSpeed)
		if(aimSwivel <= 0):
			setHands(false) #left hand
		else:
			setHands(true) #right hand
		animation.set("parameters/shootAngle/blend_position", aimSwivel)
		#correct gun angle to be parallel with ground plane, but match rotation with aimSwivel
		var gun = shootingPoint.get_parent()
		gun.set_global_rotation(Vector3(0, gun.global_rotation.y, 0))
	elif(camera == null):
		camera = get_node(NodePath("/root/Level/Camera3D"))
	else:
		worldCursor.visible = false
	
	#dodging
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
	
	#gravity
	tVelocity.y -= GRAVITY * delta
	if(Input.is_action_just_pressed("jump") and is_on_floor()):
		tVelocity.y += 15
	elif(is_on_floor()):
		tVelocity.y = -0.1
	
	#apply velocity
	set_velocity(tVelocity)
	if(dodgeVel != Vector3.ZERO):
		set_velocity(Vector3(dodgeVel.x, tVelocity.y, dodgeVel.z))
	set_up_direction(Vector3.UP)
	if(active):
		move_and_slide()

func updateGunStats():
	revolverClip = gunStats[0]
	revolverDamage = gunStats[1]
	revolverReloadTime = gunStats[2]
	shotgunClip = gunStats[3]
	shotgunDamage = gunStats[4]
	shotgunReloadTime = gunStats[5]

func setWeaponAndHands(revolver:bool, right:bool):
	if(revolver != onRevolver || right != rightHand):
		var oldGun = gunRight
		if(!rightHand):
			oldGun = gunLeft
		var gun = gunRight
		if(!right):
			gun = gunLeft
		var tempGun = oldGun.get_child(0).get_child(0)
		if(!onRevolver):
			tempGun = oldGun.get_child(1).get_child(0)
		oldGun = tempGun
		tempGun = gun.get_child(0).get_child(0)
		if(!revolver):
			tempGun = gun.get_child(1).get_child(0)
		gun = tempGun
		oldGun.visible = false
		gun.visible = true
		onRevolver = revolver
		if(onRevolver):
			shootTime = revolverShootTime
		else:
			shootTime = shotgunShootTime
		rightHand = right
		shootingPoint = gun.get_child(0)
		lineSightRaycast = shootingPoint.get_child(0)
		if(onRevolver):
			lineSightNode.transparency = lineSightTransparency
		else:
			lineSightNode.transparency = 1.0
func setHands(right:bool):
	if(right != rightHand):
		setWeaponAndHands(onRevolver, right)
func setWeapon(revolver:bool):
	idleTime = 0
	if(revolver != onRevolver):
		setWeaponAndHands(revolver, rightHand)

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
		Input.start_joy_vibration(0,1,1,0.2)
		hitpoints -= damage
		HealthBar._on_health_update_(hitpoints / maxHitpoints)
		healthCounter.updateHealth(hitpoints)
		if hitpoints <= 0 and !invincible:
			die()
		return true
	else:
		return false
		
func healFromBullet(damageDone):
	hitpoints += damageDone * lifeLeach
	if(hitpoints >= maxHitpoints):
		hitpoints = maxHitpoints
		
func die():
	# all possible bones #var phys_bones = ["Hips", "Spine", "Spine 1", "Spine2", "Neck", "LeftShoulder", "LeftArm", "leftForeArm", "LeftHand", "RightShoulder", "RightArm", "RightForeArm", "RightUpLeg", "LeftFoot", "RightFoot"]
	#testing individual bones #var phys_bones = ["LeftHand", "RightHand"]
	active = false
	rotation.x = PI / 2.0
	#skeleton.physical_bones_start_simulation(phys_bones)
