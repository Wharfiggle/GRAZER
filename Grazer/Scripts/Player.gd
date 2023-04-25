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
@onready var MainHud = $"../GameUI"
@onready var fog = get_node(NodePath("/root/Level/FogVolume"))

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
var knocked = false
var movementBlend = 0.0

#Reload variables
var currentReloadTime = 0
var revolverClip = 6
var shotgunClip = 2
var idleTime = 0
var autoReloadEnabled = false
var autoReloadTime = 5
var reloading = false
var invincible = false

var revolverimage = preload("res://Assets/Images/hud/OneDrive_1_4-12-2023/weaponHUD/revolvEquippedV2.png")
var shotgunimage = preload("res://Assets/Images/hud/OneDrive_1_4-12-2023/weaponHUD/shotgunEquippedV2.png")

#revolver capacity, revolver damage, revolver reload, shotgun capacity, shotgun damage, shotgun reload
@export var gunStats = [0, 0.0, 0.0, 0, 0.0, 0.0]
@export var revolverDamage = 3.0
@export var revolverReloadTime = 1.0
@export var revolverClipSize = 6
@export var shotgunDamage = 0.6
@export var shotgunReloadTime = 1.2
@export var shotgunClipSize = 2

var cowDamageMod = 1.0
var cowTypes = null

var potions = null
#var inventory = [0, 0, 0, 0, 0, 0]
var inventory = [5, 5, 5, 5, 5, 5]
@export var potionTime = 25.0
var potionTimer = 0.0
var potionUsed
var lifeLeach = 0.0
var potionSpeedup = 1.0
var alwaysCrit = false
var critChance = 0.1
var dauntless = false
var bulletstorm = false
var bulletColor = Color(1, 1, 0)
var lineSightColor = Color(1, 1, 1)
var critColor = Color(0, 0, 0)

var russelOrRay = WorldSave.getCharacter()

#@export var hitColor:Color
#var hitFlashAmount = 0.0
@onready var hitFlash = get_node(NodePath("./"+russelOrRay+"/Armature/Skeleton3D/Pants")).get_material_override()
@onready var healthCounter = get_node(NodePath("/root/Level/Health Counter"))
#audioStreams
@onready var gunSound = $gun
@onready var Steps = $footsteps
@onready var Vocal = $Voice
#preloading sound file
var runSound = preload("res://sounds/Foley files/Foley files (Raw)/Shoe Fast#02.wav")
var stepsSound = preload("res://sounds/Footsteps/Footsteps/CowboyStep1.wav")
var revolverShootSound = preload("res://sounds/New Sound FEX/Revolver-Impacts/revolverfire.wav")
var revolverCritSound = preload("res://sounds/New Sound FEX/Revolver-Impacts/CriticalHit1.wav")
var shotgunShootSound = preload("res://sounds/New Sound FEX/Shotgun-20230424T160416Z-001/Shotgun/shottyfire.wav")
var shotgunCritSound = preload("res://sounds/New Sound FEX/Revolver-Impacts/CriticalHit1.wav")
var usepotionS = preload("res://sounds/New Sound FEX/Elixir-Power/elixirdrink.wav")
var damagesound = preload("res://sounds/New Sound FEX/Cowboy/Damage/Cowboy - Bradl#01.47.wav")
var lungeSound = preload("res://sounds/New Sound FEX/Cowboy/Lunge_attack/Cowboy - Bradl#01.32.wav")
var reloadStartR = preload("res://sounds/New Sound FEX/Revolver-Impacts/RevReloadOpen.wav")
var reloadingSoundR = preload("res://sounds/New Sound FEX/Revolver-Impacts/RevReloadBullet.wav")
var reloadEndR = preload("res://sounds/New Sound FEX/Revolver-Impacts/RevReloadClose.wav")

var reloadStartS = preload("res://sounds/New Sound FEX/Shotgun-20230424T160416Z-001/Shotgun/ShottyReloadOpen.wav")
var reloadingSoundS = preload("res://sounds/New Sound FEX/Shotgun-20230424T160416Z-001/Shotgun/ShottyReloadBullet.wav")
var reloadEndS = preload("res://sounds/New Sound FEX/Shotgun-20230424T160416Z-001/Shotgun/ShottyReloadClose.wav")

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
@onready var gunRight = get_node(NodePath("./"+russelOrRay+"/Armature/Skeleton3D/GunRight"))
@onready var gunLeft = get_node(NodePath("./"+russelOrRay+"/Armature/Skeleton3D/GunLeft"))
var rightHand = true
var onRevolver = true
@export var shotgunRandOffset = 0.1
@export var revolverRange = 25.0
@export var shotgunRange = 6.0
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
@onready var animation = get_node(NodePath("./"+russelOrRay+"/AnimationPlayer/AnimationTree"))
@onready var skeleton = get_node(NodePath("./"+russelOrRay+"/Armature/Skeleton3D"))
@onready var worldCursor = get_node(NodePath("./WorldCursor"))
#@export var cursorSpinSpeed = 1.0
#@export var cursorSpinTime = 1.0
#var cursorSpinTimer = 0
var mousePos = Vector2.ZERO
var cursorPos = Vector3.ZERO
var rng = RandomNumberGenerator.new()
var swapInputFrames = 5
var swapInputFrameCounter = 0
var active = true
var maxAmmo = 0
var lastGroundedPosition = position


# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group('Player')
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	healthCounter.updateHealth(hitpoints)
	lineSight = lineSightMesh.duplicate()
	lineSightNode.mesh = lineSight
	lineSight.prepareForColorChange(lineSightNode)
	lineSightRaycast.target_position = Vector3(0, 0, revolverRange)
	shotgunSpread = shotgunSpread * PI / 180.0
	lineSightNode.transparency = lineSightTransparency
	
	gunStats[0] = revolverClipSize
	gunStats[1] = revolverDamage
	gunStats[2] = revolverReloadTime
	gunStats[3] = shotgunClipSize
	gunStats[4] = shotgunDamage
	gunStats[5] = shotgunReloadTime
	
	get_node(NodePath("./Russel")).visible = false
	get_node(NodePath("./"+russelOrRay)).visible = true
	
	Steps.stream = stepsSound
	
	#hitFlash.set_shader_parameter("color", hitColor)
	hitFlash.set_shader_parameter("color", Color(1, 1, 1))
	
	
	MainHud._ammo_update_(revolverClip)
	MainHud._set_ammo_Back(revolverClipSize)
	
	
	#HealthBar._on_max_health_update_(10)

	#var phys_bones = ["Hips", "Spine", "Spine 1", "Spine2", "Neck", "LeftShoulder", "LeftArm", "leftForeArm", "LeftHand", "RightShoulder", "RightArm", "RightForeArm", "RightUpLeg", "LeftFoot", "RightFoot"]
	#skeleton.physical_bones_start_simulation(phys_bones)

#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_action_just_pressed("printSceneCounter")):
		SceneCounter.printCounters()
	
	#set up list of potions and cow types, only happens once after level is done initializing
	if(potions == null):
		var level = get_node(NodePath("/root/Level"))
		if(level != null && level.has_method("getPotion")):
			potions = []
			for i in 6:
				potions.append(level.getPotion(6 + i))
			cowTypes = []
			for i in 6:
				cowTypes.append(level.CowType.new(i, self))
	
	#restart level
	if(Input.is_action_just_pressed("restart")):
		WorldSave.reset()
		get_tree().change_scene_to_file("res://Levels/Level.tscn")
		
	#swap model between ray and russel
	if(Input.is_action_just_pressed("GenderBend")):
		setModel(russelOrRay == "Ray")
	
	if(herd == null):
		herd = herdPrefab.instantiate()
		get_node(NodePath("/root/Level")).add_child(herd)
		herd.spawnCowAtPos(Vector3(position.x, position.y, position.z - 2), 0)
		#herd.spawnCowAtPos(Vector3(position.x - 1, position.y, position.z - 3), 0)
		
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
		var startTime = 0.25
		var endTime = 0.2
		var blend = 0
		var pTime = potionTime
		if(potionUsed == potions[0]):
			pTime = 1.0
		elif(potionUsed == potions[3]):
			pTime = 15.0
		if(potionTimer > pTime - startTime):
			blend = 1 - ((potionTimer - (pTime - startTime)) / startTime)
			blend = pow(blend, 2)
		elif(potionTimer > pTime - endTime - startTime):
			blend = 1 - ((potionTimer - (pTime - startTime)) / -endTime)
			blend = sqrt(blend)
		animation.set("parameters/walkEllixir/blend_amount", blend)
		var t = potionTimer / potionTime
		hitFlash.set_shader_parameter("amount", abs( sin( sqrt(t) * 100) ) / 10)
		potionTimer -= delta
		if(potionTimer < 0):
			potionTimer = 0
			potionUsed.use(false)
			potionUsed = null
			hitFlash.set_shader_parameter("amount", 0)
	
	#Temp var to allow easier comparisions
	var equippedClip
	var equippedClipSize
	if(onRevolver):
		equippedClip = revolverClip
		equippedClipSize = revolverClipSize
	else:
		equippedClip = shotgunClip
		equippedClipSize = shotgunClipSize
	
	if(!reloading):
		if(Input.is_action_just_pressed("reload") and equippedClip < equippedClipSize):
			startReload()
		if(equippedClip <= 0):
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
		if(currentReloadTime <= 0):
			currentReloadTime = 0
			finishReloading()
		
		var startTime = 0.1
		var rTime = revolverReloadTime
		if(!onRevolver):
			rTime = shotgunReloadTime
		var endTime = min(0.6, rTime - startTime)
		var startT = 1.0 - min(1.0, (rTime - currentReloadTime) / startTime)
		var endT = 1.0 - min(1.0, currentReloadTime / endTime)
		var t = startT
		if(endT != 0):
			t = endT
			if(onRevolver && gunSound.stream != reloadEndR):
				gunSound.stream = reloadEndR
				gunSound.play()
			elif(!onRevolver && gunSound.stream != reloadEndS):
				gunSound.stream = reloadEndS
				gunSound.play()
		t = 1 - pow(t, 4)
		animation.set("parameters/walkReload 2/blend_amount", t)
	
	#shoot gun input buffer
	if(Input.is_action_just_pressed("shoot") && dodgeTimer == 0 && !dauntless && !reloading):
		shootBufferTimer = shootBufferTime
	
	#shoot gun
	if(active && shootBufferTimer > 0 && shootTimer == 0 && equippedClip > 0):
		#If currently reloading, cancel reload
		if(reloading):
			currentReloadTime = 0
			reloading = false
		idleTime = 0
		
		shootBufferTimer = 0
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
		
		var bColor = bulletColor
		if(critMult == 2.0):
			bColor = critColor
		
		#Shooting the revolver
		if(onRevolver):
			revolverClip -= 1
			
			MainHud._ammo_remove_(1)
			var b = bullet.instantiate()
			b.shoot(self, "player", shootingPoint.global_position, Vector3(0, aimDir, 0),
			revolverRange, revolverDamage * critMult * cowDamageMod, critMult > 1, bColor, 150.0)
			camera.add_trauma(0.22)
			if(!critMult == 2.0):
				boomSound.stream = revolverShootSound
				boomSound.play(.55)
			else:
				boomSound.stream = revolverCritSound
				boomSound.play()
		#Shooting the shotgun
		else:
			camera.add_trauma(0.3)
			shotgunClip -= 1
			rng.randomize()
			MainHud._ammo_remove_(1)
			var bullets = 0
			while bullets < shotgunBullets:
				var b = bullet.instantiate()
				var rnSpread = rng.randf_range(-shotgunRandOffset, shotgunRandOffset)
				var rnRange = shotgunRange + rng.randf_range(-shotgunRange * shotgunRandOffset, shotgunRange * shotgunRandOffset)
				var bRotation = Vector3(0, aimDir - shotgunSpread / 2.0
					+ (shotgunSpread / (shotgunBullets - 1)) * bullets + rnSpread, 0)
				b.shoot(self, "player", shootingPoint.global_position, bRotation, 
				rnRange, shotgunDamage * critMult * cowDamageMod, critMult > 1, bColor, 50.0)
				bullets += 1
			if(!critMult == 2.0):
				boomSound.stream = revolverShootSound
				boomSound.play(.55)
			else:
				boomSound.stream = revolverCritSound
				boomSound.play()
#		if(bulletstorm):
#			shootTime = 0.1
		shootTimer = shootTime
		lineSightTimer = lineSightTime
	
	#setting sound 
	
	
	#movement
	var toAdd = Vector3()
	if(!(Input.is_action_pressed("moveRight") and Input.is_action_pressed("moveLeft"))):
		if(Input.is_action_pressed("moveRight")):
			#if (!Steps.playing):
			#Steps.play()
			toAdd.x += 1
			toAdd.z += -1
		elif(Input.is_action_pressed("moveLeft")):
			
			#Steps.play()
			toAdd.x += -1
			toAdd.z += 1
	if(!(Input.is_action_pressed("moveDown") and Input.is_action_pressed("moveUp"))):
		if(Input.is_action_pressed("moveDown")):
			
			#Steps.play()
			toAdd.x += 1
			toAdd.z += 1
		elif(Input.is_action_pressed("moveUp")):
			
			#Steps.play()
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
	elif(toAdd.length() > 0 && active):
		toAdd = toAdd.normalized()
		worldCursor.visible = true
	
	if(active):
		#adjust walking animation speed to match speed
		movementBlend = lerpf(movementBlend, toAdd.length(), 0.1)
		animation.set("parameters/idleWalk/blend_amount", movementBlend)
		if(toAdd != Vector3.ZERO):
			moveDir = atan2(toAdd.x, toAdd.z)
		
		#rotate towards where player is moving
		rotation.y = lerp_angle(
			rotation.y,
			moveDir,
			0.1)
		var cursorScale = worldCursor.scale
		worldCursor.set_global_rotation(Vector3(worldCursor.rotation.x, PI / 4.0, worldCursor.rotation.z))
		worldCursor.scale = cursorScale
	else:
		worldCursor.visible = false
		movementBlend = lerpf(movementBlend, 0, 0.1)
		animation.set("parameters/idleWalk/blend_amount", movementBlend)
	
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
		
	#update world cursor position
	worldCursor.global_position = position + cursorPos

	if(herd != null):
		for i in 6:
			if(Input.is_action_just_pressed("debug" + str(i + 1))):
				herd.spawnCow(i)
		
		if(Input.is_action_just_pressed("Follow Wait") && active):
			herd.toggleFollow()
	else:
		print("fuck there is no herd") #yeah

func setModel(inRusselOrRay:bool):
	if(inRusselOrRay == (russelOrRay == "Russel")):
		return
	WorldSave.setCharacter(inRusselOrRay)
	var model = get_node(NodePath("./" + russelOrRay))
	model.visible = false
	if(inRusselOrRay):
		russelOrRay = "Russel"
	else:
		russelOrRay = "Ray"
	model = get_node(NodePath("./" + russelOrRay))
	model.visible = true
	hitFlash = get_node(NodePath("./"+russelOrRay+"/Armature/Skeleton3D/Pants")).get_material_override()
	gunRight = get_node(NodePath("./"+russelOrRay+"/Armature/Skeleton3D/GunRight"))
	gunLeft = get_node(NodePath("./"+russelOrRay+"/Armature/Skeleton3D/GunLeft"))
	animation = get_node(NodePath("./"+russelOrRay+"/AnimationPlayer/AnimationTree"))
	skeleton = get_node(NodePath("./"+russelOrRay+"/Armature/Skeleton3D"))
	setWeaponAndHands(onRevolver, rightHand)
#	var gun = gunRight
#	if(!rightHand):
#		gun = gunLeft
#	shootingPoint = gun.find_child("ShootingPoint")
#	lineSightRaycast = shootingPoint.get_child(0)
#	if(onRevolver):
#		lineSightNode.transparency = lineSightTransparency

func setLineSightColor(inColor:Color = Color(1, 1, 1)):
	lineSightColor = inColor
	lineSight.setColor(inColor)

func setBulletColor(inColor:Color = Color(1, 1, 0)):
	bulletColor = inColor

func usePotion(ind:int):
	if(inventory[ind] > 0):
		#put sound here
		Vocal.stream = usepotionS
		Vocal.play()
		if(potionUsed != null):
			potionUsed.use(false)
		potions[ind].use()
		inventory[ind] -= 1
		potionTimer = potionTime
		if(ind == 0):
			potionTimer = 1.0
		elif(ind == 3):
			potionTimer = 15.0
		potionUsed = potions[ind]

func startReload():
	if (onRevolver):
		gunSound.stream = reloadStartR
		gunSound.play()
	else :
		gunSound.stream = reloadStartS
		gunSound.play()
	
	print("Reloading")
	reloading = true
	if(onRevolver):
		currentReloadTime = revolverReloadTime
	else:
		currentReloadTime = shotgunReloadTime
	if(bulletstorm):
		currentReloadTime = 0.001
	idleTime = 0

func cancelReloading():
	reloading = false
	animation.set("parameters/walkReload 2/blend_amount", 0)
	currentReloadTime = 0
	idleTime = 0

func finishReloading():
	animation.set("parameters/walkReload 2/blend_amount", 0)
	print("Finished Reloading")
	reloading = false
	idleTime = 0
	if(onRevolver):
		revolverClip = revolverClipSize
		MainHud._ammo_update_(revolverClip)
		
	else:
		shotgunClip = shotgunClipSize
		MainHud._ammo_update_(shotgunClip)
		

func _physics_process(delta):
	#hit flash on being hit
#	if(hitFlashAmount > 0.1):
#		hitFlash.set_shader_parameter("amount", hitFlashAmount)
#		hitFlashAmount = lerpf(hitFlashAmount, 0, 0.3)
#		if(hitFlashAmount < 0.1):
#			hitFlashAmount = 0
#			hitFlash.set_shader_parameter("amount", 0.0)
#			hitFlash.set_shader_parameter("color", hitColor)
	
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
			cancelReloading()
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
		
		if(dodgeTimer == 0 && !reloading):
			lineSightNode.visible = true
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
			var gunScale = gun.scale
			if(abs(prevAimSwivel - aimSwivel) < 0.01):
				#do this when arms are aiming same direction as cursor to fix gun slowly becoming offset
				gun.set_global_rotation(Vector3(0, aimDir, 0))
			else:
				gun.set_global_rotation(Vector3(0, gun.global_rotation.y, 0))
			gun.scale = gunScale
		else:
			lineSightNode.visible = false
	elif(camera == null):
		camera = get_node(NodePath("/root/Level/Camera3D"))
	else:
		worldCursor.visible = false
	
	#dodging
	if(Input.is_action_just_pressed("dodge") && active):
		dodgeBufferTimer = dodgeBufferTime
	elif(dodgeBufferTimer > 0):
		dodgeBufferTimer -= delta
		if(dodgeBufferTimer < 0):
			dodgeBufferTimer = 0
	if(active && dodgeBufferTimer > 0 && dodgeCooldownTimer == 0):
		Input.start_joy_vibration(0,0.6,0.6,.1)
		if(Vocal.stream != lungeSound):
			Vocal.stream = lungeSound
			Vocal.play()
		dodgeCooldownTimer = dodgeCooldownTime
		if(dauntless):
			dodgeCooldownTimer = 0.001
		dodgeTimer = dodgeTime
		dodgeBufferTimer = 0
		dodgeVel = Vector3(sin(moveDir), 0, cos(moveDir)) * dodgeSpeed
	if(dodgeTimer > 0):
		dodgeTimer -= delta
		if(dauntless):
			dodgeTimer -= delta * 0.5
		if(dodgeTimer < 0):
			dodgeTimer = 0
			Vocal.stream = null
			animation.set("parameters/walkLunge/blend_amount", 0)
			knocked = false
			dodgeVel = Vector3.ZERO
			tVelocity = Vector3.ZERO
		else:
			var t = dodgeTimer / dodgeTime
			t = sqrt(t)
			var knockMod = 1.0
			if(knocked):
				knockMod = 0.5
			#print(Vector3(sin(moveDir), 0, cos(moveDir)))
			dodgeVel = Vector3(sin(moveDir), 0, cos(moveDir)) * dodgeSpeed * t * knockMod
		if(dauntless):
			dodgeVel *= 1.5
		knock()
		
		var startTime = 0.1
		var blend = 0
		if(dodgeTimer > dodgeTime - startTime):
			blend = 1 - ((dodgeTimer - (dodgeTime - startTime)) / startTime)
		else:
			blend = dodgeTimer / (dodgeTime - startTime)
			blend = blend
		animation.set("parameters/walkLunge/blend_amount", blend)
	elif(dodgeCooldownTimer > 0):
		dodgeCooldownTimer -= delta
		if(dodgeCooldownTimer < 0):
			dodgeCooldownTimer = 0
	
	if(active):
		#gravity
		tVelocity.y -= GRAVITY * delta
		var grounded = is_on_floor()
		if(Input.is_action_just_pressed("jump") and grounded):
			tVelocity.y += 15
		elif(grounded):
			tVelocity.y = -0.1
		elif(position.y < -10.0):
			updateHealth(hitpoints - 4)
			if(active):
				position = Vector3(lastGroundedPosition.x, 0.5, lastGroundedPosition.z)
				lastGroundedPosition.y = 0
				tVelocity.y = -0.1
	else:
		tVelocity.y = 0
	
	#apply velocity
	set_velocity(tVelocity)
	if(dodgeVel != Vector3.ZERO):
		set_velocity(Vector3(dodgeVel.x, tVelocity.y, dodgeVel.z))
	set_up_direction(Vector3.UP)
	if(active):
		move_and_slide()
		fog.position = Vector3(position.x, fog.position.y, position.z)
		
	if(is_on_floor()):
		if(position.y > -0.5 && position.y < 0.5):
			if(lastGroundedPosition.y >= 60):
				lastGroundedPosition = Vector3(position.x, 0, position.z)
			else:
				lastGroundedPosition.y += 1

func updateGunStats():
	revolverClipSize = gunStats[0]
	revolverDamage = gunStats[1]
	revolverReloadTime = gunStats[2]
	shotgunClipSize = gunStats[3]
	shotgunDamage = gunStats[4]
	shotgunReloadTime = gunStats[5]
	

func setWeaponAndHands(revolver:bool, right:bool):
	gunRight.get_child(0).get_child(0).visible = false
	gunRight.get_child(1).get_child(0).visible = false
	gunLeft.get_child(0).get_child(0).visible = false
	gunLeft.get_child(1).get_child(0).visible = false
#	var oldGun = gunRight
#	if(!rightHand):
#		oldGun = gunLeft
	var gun = gunRight
	if(!right):
		gun = gunLeft
#	var tempGun = oldGun.get_child(0).get_child(0)
#	if(!onRevolver):
#		tempGun = oldGun.get_child(1).get_child(0)
#	oldGun = tempGun
	var tempGun = gun.get_child(0).get_child(0)
	if(!revolver):
		tempGun = gun.get_child(1).get_child(0)
	gun = tempGun
#	oldGun.visible = false
	gun.visible = true
	onRevolver = revolver
	if(onRevolver):
		shootTime = revolverShootTime
	else:
		shootTime = shotgunShootTime
	rightHand = right
	shootingPoint = gun.find_child("ShootingPoint")
	lineSightRaycast = shootingPoint.get_child(0)
	if(onRevolver):
		lineSightNode.transparency = lineSightTransparency
		MainHud._ammo_update_(revolverClip)
		MainHud._set_ammo_Back(revolverClipSize)
		MainHud._set_weapon_image_(revolverimage)
		MainHud.move_ammoHold_(true)
		
	else:
		lineSightNode.transparency = 1.0
		MainHud._ammo_update_(shotgunClip)
		MainHud._set_ammo_Back(shotgunClipSize)
		MainHud._set_weapon_image_(shotgunimage)
		MainHud.move_ammoHold_(false)
		
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
			#print("player knockback: " + str(enemy.global_position - Vector3(sin(moveDir), 0, cos(moveDir))))
			var newKnockback = enemy.knockback(enemy.global_position - Vector3(sin(moveDir), 0, cos(moveDir)), dodgeVel.length(), true)
			if(dauntless && newKnockback):
				enemy.damage_taken(4 * cowDamageMod, "player", false)
			camera.add_trauma(0.3)
			knocked = true

func updateHealth(newHP:float):
	hitpoints = newHP
	MainHud._on_health_update_(hitpoints / maxHitpoints)
	healthCounter.updateHealth(hitpoints)
	if(hitpoints <= 0 and !invincible):
		die()
	if(hitpoints > maxHitpoints):
		hitpoints = maxHitpoints

func damage_taken(damage:float, from:String, _inCritHit:bool = false, _inBullet:Node = null) -> bool:
	if(from != "player"):
		print("player damaged")
		Vocal.stream = damagesound
		if(!Vocal.playing):
			Vocal.play()
#		hitFlashAmount = 1
		Input.start_joy_vibration(0,1,1,0.2)
		camera.add_trauma(0.35)
		updateHealth(hitpoints - damage)
		return true
	else:
		return false
		
func healFromBullet(damageDone):
	updateHealth(hitpoints + damageDone * lifeLeach)
		
func die():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# all possible bones #var phys_bones = ["Hips", "Spine", "Spine 1", "Spine2", "Neck", "LeftShoulder", "LeftArm", "leftForeArm", "LeftHand", "RightShoulder", "RightArm", "RightForeArm", "RightUpLeg", "LeftFoot", "RightFoot"]
	#testing individual bones #var phys_bones = ["LeftHand", "RightHand"]
	active = false
	rotation.x = PI / 2.0
	lineSightNode.visible = false 
	animation.set("parameters/idleWalk/blend_amount", 0)
	animation.set("parameters/walkShoot/blend_amount", 0.1)
	animation.set("parameters/shootAngle/blend_position", 1)
	#skeleton.physical_bones_start_simulation(phys_bones)
