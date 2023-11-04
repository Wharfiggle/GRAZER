extends CharacterBody3D

var invincible = false

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
@export var dodgeSpeed = 12
@export var dodgeSpeedIncrease = 5
var dodgeVel = Vector3(0,0,0)
@export var dodgeTime = 0.5
var dodgeTimer = 0.0
@export var dodgeCooldownTime = 0.7
var dodgeCooldownTimer = 0.0
@export var dodgeBufferTime = 0.1
var dodgeBufferTimer = 0.0
var knocked = false
var movementBlend = 0.0

#var volume = 1
#var hibernate = false
#@onready var terrain = get_node("/root/Level/AllTerrain")

#Reload variables
var currentReloadTime = 0
var revolverClip = 6
var shotgunClip = 2
var idleTime = 0
var autoReloadEnabled = false
var autoReloadTime = 5
var reloading = false

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
var inventory = [0, 0, 0, 0, 0, 0]
#var inventory = [5, 5, 5, 5, 5, 5]
@export var potionTime = 25.0
var potionTimer = 0.0
var potionUsed
var lifeLeach = 0.0
var potionSpeedup = 1.0
var alwaysCrit = false
var startCritChance = 0.05
var critChance = startCritChance
var dauntless = false
var bulletstorm = false
var bulletColor = Color(1, 1, 0)
var lineSightColor = Color(1, 1, 1)
var critColor = Color(0, 0, 0)
var luckies = 0
var grandReds = 0
var startLungeEffectiveness = 0.8
var lungeEffectiveness = startLungeEffectiveness
var justKnocked = []
@export var discombobulateTime = 5.0

var russelOrRay = WorldSave.getCharacter()

#@export var hitColor:Color
#var hitFlashAmount = 0.0
@onready var hitFlash = get_node(NodePath("./"+russelOrRay+"/Armature" + (" Hope" if russelOrRay=="Russel" else "") + "/Skeleton3D/Pants" + ("001" if russelOrRay=="Ray" else ""))).get_material_override()
@onready var healthCounter = get_node(NodePath("/root/Level/Health Counter"))
#audioStreams
@onready var gunSound = $gun
@onready var Steps = $footsteps
@onready var Vocal = $Voice
@onready var extraSounds = $potions
#preloading sound file
var runSound = preload("res://sounds/Foley files/Foley files (Raw)/Shoe Fast#02.wav")
var stepsSound = preload("res://sounds/Footsteps/Footsteps/CowboyStep1.wav")

var revolverShootSound = preload("res://sounds/New Sound FEX/Revolver-Impacts/revolverfire.wav")
var revolverCritSound = preload("res://sounds/New Sound FEX/Revolver-Impacts/CriticalHit1.wav")
var shotgunShootSound = preload("res://sounds/New Sound FEX/Shotgun-20230424T160416Z-001/Shotgun/shottyfire.wav")
var shotgunCritSound = preload("res://sounds/New Sound FEX/Revolver-Impacts/CriticalHit1.wav")

var usepotionS = preload("res://sounds/newSounds/Elixir-Power/elixirdrink.wav")
var damagesound = preload("res://sounds/New Sound FEX/Cowboy/Damage/Cowboy - Bradl#01.47.wav")
var lungeSound = preload("res://sounds/New Sound FEX/Cowboy/Lunge_attack/Cowboy - Bradl#01.32.wav")
var reloadStartR = preload("res://sounds/New Sound FEX/Revolver-Impacts/RevReloadOpen.wav")
var reloadingSoundR = preload("res://sounds/New Sound FEX/Revolver-Impacts/RevReloadBullet.wav")
var reloadEndR = preload("res://sounds/New Sound FEX/Revolver-Impacts/RevReloadClose.wav")

var physicalHurt = preload("res://sounds/LungeImpact.wav")

var reloadStartS = preload("res://sounds/New Sound FEX/Shotgun-20230424T160416Z-001/Shotgun/ShottyReloadOpen.wav")
var reloadingSoundS = preload("res://sounds/New Sound FEX/Shotgun-20230424T160416Z-001/Shotgun/ShottyReloadBullet.wav")
var reloadEndS = preload("res://sounds/New Sound FEX/Shotgun-20230424T160416Z-001/Shotgun/ShottyReloadClose.wav")

var potionPowerDown = preload("res://sounds/newSounds/Elixir-Power/powerdown.wav")
#var potionPowerUP = preload("res://sounds/New Sound FEX/Elixir-Power/powerup.wav")

var RayHurtSound = preload("res://sounds/Cowgirl edited/Damage/Cowgirl Damage Take 4#01.3.wav")
var rayLungesound = preload("res://sounds/Cowgirl edited/Lunges/Lunge#01.3.wav")

var whistle1 = preload("res://sounds/newSounds/Whistle/Whistle1.wav")
var whistle2 = preload("res://sounds/newSounds/Whistle/Whistle2.wav")

var GRAVITY = 30
@export var speed = 8.0
var herdPrefab = preload("res://Prefabs/Herd.tscn")
var herd
#@onready var camera = get_node(NodePath("/root/Level/Camera3D"))
var camera = null
var moveDir = PI * 5.0 / 8.0
var prevAimDir = [0, 0, 0, 0, 0]
var aimDir = 0.0
var aimSwivel = 0.0
var handTransition = 0.0
@export var swivelSpeed = 0.2
@onready var gunRight = get_node(NodePath("./"+russelOrRay+"/Armature" + (" Hope" if russelOrRay=="Russel" else "") + "/Skeleton3D/GunRight"))
@onready var gunLeft = get_node(NodePath("./"+russelOrRay+"/Armature" + (" Hope" if russelOrRay=="Russel" else "") + "/Skeleton3D/GunLeft"))
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
@export var lineSightTransparency = 0.25
@export var lineSightTime = 0.8
var lineSightTimer = 0.0
var lineSight
@onready var animation = get_node(NodePath("./"+russelOrRay+"/AnimationPlayer/AnimationTree"))
@onready var skeleton = get_node(NodePath("./"+russelOrRay+"/Armature" + (" Hope" if russelOrRay=="Russel" else "") + "/Skeleton3D"))
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
@onready var lastGroundedPosition = position
@onready var deathMenu = $"../DeathMenu"

var deathBlend = 0
var deathTimer = 0
var dead = false

@export var canHaveNoCows = false
@onready var checkpoint = position
var checkpointCowAmmount = 0
@export var noRevolver = false
@export var noShotgun = false
@onready var healthPulse = $"../HealthPulse".material
var healthPulseIntensity = 0.0
var resetHealthPulse = true

var playerIdlingTime = 3.0
var playerIdlingTimer = 1.5
var playerIdling = false
var armsLowering = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group('Player')
	#healthCounter.updateHealth(hitpoints)
	lineSight = lineSightMesh.duplicate()
	lineSightNode.mesh = lineSight
	lineSight.prepareForColorChange(lineSightNode, true)
	lineSightRaycast.target_position = Vector3(0, 0, revolverRange)
	shotgunSpread = shotgunSpread * PI / 180.0
	lineSight.updateMaxOpacity(1.0 - lineSightTransparency)
	
	if(noRevolver or noShotgun):
		setWeaponAndHands(onRevolver, rightHand)
	
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
	if(!playerIdling):
		armsLowering = lerp(armsLowering, 0.0, 0.3)
		if(armsLowering < 0.01):
			armsLowering = 0.0
		playerIdlingTimer -= delta
		if(playerIdlingTimer <= 0 or (noRevolver and noShotgun)):
			switchIdle(true)
	else:
		armsLowering = lerp(armsLowering, 1.0, 0.3)
	animation.set("parameters/AnimIdleBlend/blend_amount", armsLowering)
	
	if(healthPulse != null):
		if(resetHealthPulse):
			healthPulse.set_shader_parameter("intensity", 0)
			resetHealthPulse = false
	else:
		healthPulse = $"../HealthPulse".material
	
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
#	if(Input.is_action_just_pressed("restart")):
##		WorldSave.reset()
##		get_tree().change_scene_to_file("res://Levels/Level.tscn")
#		die()
		
	#swap model between ray and russel
	if(Input.is_action_just_pressed("GenderBend")):
		setModel(russelOrRay == "Ray")
	
	if(herd == null):
		herd = herdPrefab.instantiate()
		get_node(NodePath("/root/Level")).add_child(herd)
		#spawn cows at start
		var terrain = get_node("../AllTerrain")
		if(terrain.real):
			var newCows = WorldSave.cows
			for i in len(newCows):
				herd.spawnCowAtPos(Vector3(position.x + (rng.randf() * 2 - 1) - 1, position.y, position.z + (rng.randf() * 2 - 1) - 4), newCows[i])
#		for i in 6:
#			herd.spawnCowAtPos(Vector3(position.x + (rng.randf() * 2 - 1) - 1, position.y, position.z + (rng.randf() * 2 - 1) - 4), i)
#		for i in 5:
#			herd.spawnCowAtPos(Vector3(position.x + (rng.randf() * 2 - 1) - 1, position.y, position.z + (rng.randf() * 2 - 1) - 4), 3)
		
	if(herd.getNumCows() < 1 and !canHaveNoCows and !invincible):
		die()
	elif(herd.getNumCows() > 0):
		canHaveNoCows = false
	
	if(lineSightTimer > 0 && !noRevolver):
		lineSightTimer -= delta
		if(lineSightTimer <= 0):
			lineSightTimer = 0
		if(onRevolver):
			var transp = sqrt(sqrt(lineSightTimer / lineSightTime)) * (1.0 - lineSightTransparency) + lineSightTransparency
			lineSight.updateMaxOpacity(1.0 - transp)
	elif(noRevolver || !onRevolver):
		lineSight.updateMaxOpacity(0)
	else:
		lineSight.updateMaxOpacity(1.0 - lineSightTransparency)
			
	if(shootTimer > 0):
		shootTimer -= delta
		if(shootTimer <= 0):
			shootTimer = 0
	if(shootBufferTimer > 0):
		shootBufferTimer -= delta
		if(shootBufferTimer <= 0):
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
		animation.set("parameters/elixirBlend/blend_amount", blend)
		var t = potionTimer / potionTime
		hitFlash.set_shader_parameter("amount", abs( sin( sqrt(t) * 100) ) / 10)
		potionTimer -= delta
		if(potionTimer <= 0):
			potionTimer = 0
			if(potionUsed != potions[0]):
				extraSounds.stream = potionPowerDown
			extraSounds.play()
			potionUsed.use(false)
			potionUsed = null
			hitFlash.set_shader_parameter("amount", 0)
	
	#Temp var to allow easier comparisions
	var equippedClip
	var equippedClipSize
	if(onRevolver && !noRevolver):
		equippedClip = revolverClip
		equippedClipSize = revolverClipSize
	elif(!onRevolver && !noShotgun):
		equippedClip = shotgunClip
		equippedClipSize = shotgunClipSize
	elif(onRevolver && !noShotgun):
		setWeapon(false)
	elif(!onRevolver && !noRevolver):
		setWeapon(true)
	else:
		equippedClip = -1
		equippedClipSize = -1
	
	if(!reloading and !(noRevolver and noShotgun)):
		if(Input.is_action_just_pressed("reload") and equippedClip < equippedClipSize && active):
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
		animation.set("parameters/reloadBlend/blend_amount", t)
	
	#shoot gun input buffer
	if(active && Input.is_action_just_pressed("shoot") && dodgeTimer == 0 && !dauntless && !reloading):
		shootBufferTimer = shootBufferTime
	elif(Input.is_action_just_pressed("shoot")):
		print("tried to shoot, but couldn't because ")
		if(!active): print(" not active ")
		if(dodgeTimer != 0): print(" dodgeTimer not zero ")
		if(dauntless): print(" dauntless ")
		if(reloading): print(" reloading ")
	
	#shoot gun
	if(active && shootBufferTimer > 0 && shootTimer == 0 && equippedClip > 0):
		switchIdle(false)
		
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
			camera.add_trauma(0.25)
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
	elif(toAdd.length() > 0 && active):
		toAdd = toAdd.normalized()
		worldCursor.visible = true
	
	if(active):
		#adjust walking animation speed to match speed
		movementBlend = lerpf(movementBlend, 1.0 - toAdd.length(), 0.1)
		animation.set("parameters/walkIdleBlend/blend_amount", movementBlend)
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
		
		toAdd = toAdd * speed * potionSpeedup
		if(toAdd.x == 0 and toAdd.z == 0):
			tVelocity.x = lerp(tVelocity.x,0.0,0.1)
			tVelocity.z = lerp(tVelocity.z,0.0,0.1)
			herd.canHuddle = true
		else:
			switchIdle(false)
			herd.clearHuddle()
			herd.canHuddle = false
			tVelocity.x = toAdd.x
			tVelocity.z = toAdd.z
	else:
		worldCursor.visible = false
		movementBlend = lerpf(movementBlend, 1, 0.1)
		animation.set("parameters/walkIdleBlend/blend_amount", movementBlend)
	
	lineSightNode.global_position = shootingPoint.global_position
	lineSightNode.global_rotation = Vector3(0, aimDir, 0)
		
	#update world cursor position
	worldCursor.global_position = position + cursorPos

	if(herd != null):
		for i in 6:
			if(Input.is_action_just_pressed("debug" + str(i + 1))):
				herd.spawnCow(i)
		
		if(Input.is_action_just_pressed("Follow Wait") && active):
			Vocal.stream = whistle2
			if(herd.follow):
				Vocal.stream = whistle1
			Vocal.play()
			herd.toggleFollow()
	else:
		print("there is no herd?")

func switchIdle(idling:bool):
	print("switched to " + str(idling))
	print(playerIdlingTimer)
	if(idling != playerIdling):
		if(!idling):
			playerIdlingTimer = playerIdlingTime
			playerIdling = false
		else:
			playerIdling = true

func setModel(inRusselOrRay:bool):
	if(inRusselOrRay == (russelOrRay == "Russel")):
		return
	WorldSave.setCharacter(inRusselOrRay)
	var model = get_node(NodePath("./" + russelOrRay))
	model.visible = false
	model.get_node(NodePath("./AnimationPlayer")).stop()
	if(inRusselOrRay):
		russelOrRay = "Russel"
	else:
		russelOrRay = "Ray"
	model = get_node(NodePath("./" + russelOrRay))
	model.visible = true
	model.get_node(NodePath("./AnimationPlayer")).play()
	hitFlash = get_node(NodePath("./"+russelOrRay+"/Armature" + (" Hope" if russelOrRay=="Russel" else "") + "/Skeleton3D/Pants" + ("001" if russelOrRay=="Ray" else ""))).get_material_override()
	gunRight = get_node(NodePath("./"+russelOrRay+"/Armature" + (" Hope" if russelOrRay=="Russel" else "") + "/Skeleton3D/GunRight"))
	gunLeft = get_node(NodePath("./"+russelOrRay+"/Armature" + (" Hope" if russelOrRay=="Russel" else "") + "/Skeleton3D/GunLeft"))
	animation = get_node(NodePath("./"+russelOrRay+"/AnimationPlayer/AnimationTree"))
	skeleton = get_node(NodePath("./"+russelOrRay+"/Armature" + (" Hope" if russelOrRay=="Russel" else "") + "/Skeleton3D"))
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

func stunEnemies():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for i in enemies:
		if(i.currentMode != i.behaviors.hibernate):
			i.knockback(position, 1.0, false, discombobulateTime)

func usePotion(ind:int):
	if(inventory[ind] > 0):
		#put sound here
		Vocal.stream = usepotionS
		Vocal.play()
#		await Vocal.finished
#		Vocal.stream = potionPowerUP
#		Vocal.play()
		if(potionUsed != null):
			potionUsed.use(false)
		potions[ind].use()
		inventory[ind] -= 1
		potionTimer = potionTime
		if(ind == 0):
			potionTimer = 1.0
		elif(ind == 3):
			potionTimer = discombobulateTime
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
	animation.set("parameters/reloadBlend/blend_amount", 0)
	currentReloadTime = 0
	idleTime = 0

func finishReloading():
	animation.set("parameters/reloadBlend/blend_amount", 0)
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
	#hit flash on being hit (discarded because it was unnecessary and was better used as glows for potion effects)
#	if(hitFlashAmount > 0.1):
#		hitFlash.set_shader_parameter("amount", hitFlashAmount)
#		hitFlashAmount = lerpf(hitFlashAmount, 0, 0.3)
#		if(hitFlashAmount < 0.1):
#			hitFlashAmount = 0
#			hitFlash.set_shader_parameter("amount", 0.0)
#			hitFlash.set_shader_parameter("color", hitColor)
	
#	if(terrain != null):
#		var chunk = terrainController.getPlayerChunk(position)
#		print(chunk)
#		var activeInd = terrain.activeCoord.find(chunk)
#		setHibernate(activeInd == -1 || terrain.activeChunks[activeInd].loading != false)
#		print(terrain.activeChunks[activeInd])
#	else:
#		setHibernate(true)
#		terrain = get_node("/root/Level/AllTerrain")
	
	if(deathTimer > 0):
		deathTimer -= delta
		if(deathTimer <= 0):
			deathTimer = 0
			animation.set("parameters/DeathTime/scale", 0)
		deathBlend = lerpf(deathBlend, 1, 0.3)
		animation.set("parameters/DeathBlend/blend_amount", deathBlend)
	
	#swap weapon
	if(active && !noRevolver && !noShotgun):
		var swapInput = 0
		if(Input.is_action_just_released("SwapWeapon")): swapInput = 1
		elif(Input.is_action_just_released("SwapWeaponDown")): swapInput = -1
		if( (swapInputFrameCounter == 0 && swapInput != 0) 
		|| (swapInput > 0 && swapInputFrameCounter < 0) 
		|| (swapInput < 0 && swapInputFrameCounter > 0) ):
			setWeapon(!onRevolver)
			swapInputFrameCounter = swapInputFrames * swapInput
			cancelReloading()
			gunSound.stop()
		elif(swapInputFrameCounter != 0 && swapInput == 0):
			swapInputFrameCounter -= swapInputFrameCounter / abs(swapInputFrameCounter)
	
	#line of sight
	if(lineSightRaycast.is_colliding()):
		var dist = (lineSightRaycast.get_collision_point() - lineSightRaycast.global_position).length()
		lineSight.updateTrail([Vector3.ZERO, Vector3(0, 0, dist)])
	else:
		lineSight.updateTrail([Vector3.ZERO, Vector3(0, 0, revolverRange)])
	lineSight.updateCamCenter(position)
	
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
			if(!noRevolver or !noShotgun):
				switchIdle(false)
		elif(leftStick.length() > 0.3):
			aimDir = -atan2(leftStick.z, leftStick.x) - PI * 5.0 / 4.0
			worldCursor.visible = false
			switchIdle(false)
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
			if(prevMousePos != mousePos):
				if(!noRevolver or !noShotgun):
					switchIdle(false)
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
		#account for crossover from 0 to 2 * PI or vice versa
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
			var prevHandTransition = handTransition
			handTransition = lerpf(prevHandTransition, 0, swivelSpeed / 2)
			var justSwitched = false
			if(noRevolver and noShotgun):
				animation.set("parameters/rightAim/blend_amount", 0)
				animation.set("parameters/rightArmBlend/blend_amount", 0)
				animation.set("parameters/leftAim/blend_amount", 0)
				animation.set("parameters/leftArmBlend/blend_amount", 0)
				armsLowering = 1.0
			elif(aimSwivel <= 0): #left hand
				if(prevAimSwivel > 0 or rightHand == null):
					handTransition = 2
					justSwitched = true
					setHands(false)
				var armBlend = 1.0 - (max(1.0, handTransition) - 1.0)
				animation.set("parameters/leftAim/blend_amount", (aimSwivel * 2 + 1)) # * armBlend + 1 - armBlend
				animation.set("parameters/leftArmBlend/blend_amount", armBlend)
				animation.set("parameters/rightArmBlend/blend_amount", min(1.0, handTransition))
			else: #right hand
				if(prevAimSwivel <= 0 or rightHand == null):
					handTransition = 2
					justSwitched = true
					setHands(true)
				var armBlend = 1.0 - (max(1.0, handTransition) - 1.0)
				animation.set("parameters/rightAim/blend_amount", -(aimSwivel * 2 - 1))
				animation.set("parameters/leftArmBlend/blend_amount", min(1.0, handTransition))
				animation.set("parameters/rightArmBlend/blend_amount", armBlend)
			if(armsLowering > 0):
				lineSightNode.visible = false
				var t = 1.0 - armsLowering
				animation.set("parameters/rightAim/blend_amount", t)
				animation.set("parameters/rightArmBlend/blend_amount", t)
				animation.set("parameters/leftAim/blend_amount", t)
				animation.set("parameters/leftArmBlend/blend_amount", t)
			#correct gun angle to be parallel with ground plane, but match rotation with aimSwivel
			var gun = shootingPoint.get_parent()
			var gunScale = gun.scale
			if(armsLowering == 0):
				gun.set_global_rotation(Vector3(0, aimDir, 0))
			#i dont remember why i did this since just always setting rotation.y to aimDir works better
#			if(abs(prevAimSwivel - aimSwivel) < 0.01):
#				#do this when arms are aiming same direction as cursor to fix gun slowly becoming offset
#				gun.set_global_rotation(Vector3(0, aimDir, 0))
#			else:
#				gun.set_global_rotation(Vector3(0, gun.global_rotation.y, 0))
			gun.scale = gunScale
		else:
			lineSightNode.visible = false
	elif(camera == null):
		camera = get_node(NodePath("/root/Level/Camera3D"))
		camera.set_idle_sway(0.5)
	else:
		worldCursor.visible = false
	
	#dodging
	if(Input.is_action_just_pressed("dodge") && active):
		switchIdle(false)
		dodgeBufferTimer = dodgeBufferTime
	elif(dodgeBufferTimer > 0):
		dodgeBufferTimer -= delta
		if(dodgeBufferTimer <= 0):
			dodgeBufferTimer = 0
	if(active && dodgeBufferTimer > 0 && dodgeCooldownTimer == 0):
		herd.clearHuddle()
		Input.start_joy_vibration(0,0.6,0.6,.1)
		if(russelOrRay == "Russel"):
			if(Vocal.stream != lungeSound):
				Vocal.stream = lungeSound
				if(!Vocal.playing):
#					Vocal.volume_db = volume-15
#					print(Vocal.volume_db)
					Vocal.play()
		if(russelOrRay == "Ray"):
			if(Vocal.stream != rayLungesound):
				Vocal.stream = rayLungesound
				if(!Vocal.playing):
					Vocal.play()
		dodgeCooldownTimer = dodgeCooldownTime
		if(dauntless):
			dodgeCooldownTimer = 0.001
		dodgeTimer = dodgeTime
		dodgeBufferTimer = 0
		dodgeVel = Vector3(sin(moveDir), 0, cos(moveDir)) * (dodgeSpeed + dodgeSpeedIncrease * lungeEffectiveness)
		justKnocked.clear()
	if(dodgeTimer > 0):
		dodgeTimer -= delta
		if(dauntless):
			dodgeTimer -= delta * 0.5
		if(dodgeTimer <= 0):
			dodgeTimer = 0
			Vocal.stream = null
			animation.set("parameters/lungeBlend/blend_amount", 0)
			knocked = false
			dodgeVel = Vector3.ZERO
			#tVelocity = Vector3.ZERO
		else:
			var t = dodgeTimer / dodgeTime
			t = sqrt(t)
			var knockMod = 1.0
			if(knocked):
				knockMod = 0.5
			#print(Vector3(sin(moveDir), 0, cos(moveDir)))
			dodgeVel = Vector3(sin(moveDir), 0, cos(moveDir)) * max(speed * potionSpeedup, (dodgeSpeed + dodgeSpeedIncrease * lungeEffectiveness) * t * knockMod)
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
		animation.set("parameters/lungeBlend/blend_amount", blend)
	elif(dodgeCooldownTimer > 0):
		dodgeCooldownTimer -= delta
		if(dodgeCooldownTimer <= 0):
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
			gunSound.stream = physicalHurt
			gunSound.play()
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

#func setHibernate(inHibernate:bool):
#	hibernate = inHibernate
#	if(hibernate):
#		GRAVITY = 0
#		position.y = 0
#	else:
#		GRAVITY = 30

func updateGunStats():
	revolverClipSize = gunStats[0]
	revolverDamage = gunStats[1]
	revolverReloadTime = gunStats[2]
	shotgunClipSize = gunStats[3]
	shotgunDamage = gunStats[4]
	shotgunReloadTime = gunStats[5]
	
	if(onRevolver):
		MainHud._set_ammo_Back(revolverClipSize)
	else:
		MainHud._set_ammo_Back(shotgunClipSize)
	

func setWeaponAndHands(revolver:bool, right:bool):
	gunRight.get_child(0).get_child(0).visible = false
	gunRight.get_child(1).get_child(0).visible = false
	gunLeft.get_child(0).get_child(0).visible = false
	gunLeft.get_child(1).get_child(0).visible = false
	if(noRevolver and noShotgun):
		MainHud._ammo_update_(0)
		MainHud._set_ammo_Back(0)
		MainHud._set_weapon_image_(null)
		MainHud.move_ammoHold_(true)
	if(revolver && noRevolver):
		return
	elif(!revolver && noShotgun):
		return
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
		lineSight.updateMaxOpacity(1.0 - lineSightTransparency)
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

func setLuckies(l):
	luckies = l
	critChance = startCritChance
	var currentCritMod = 0.1
	for i in luckies:
		if(i > 0):
			currentCritMod -= 0.1 * currentCritMod
		critChance += currentCritMod
	
func setGrandReds(gr):
	grandReds = gr
	lungeEffectiveness = startLungeEffectiveness
	var currentLungeMod = 0.4
	for i in grandReds:
		if(i > 0):
			currentLungeMod -= 0.2 * currentLungeMod
		lungeEffectiveness += currentLungeMod

func knock():
	var enemies = knockbox.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.has_method("knockback") && !justKnocked.has(enemy):
			#print("player knockback: " + str(enemy.global_position - Vector3(sin(moveDir), 0, cos(moveDir))))
			var newKnockback = enemy.knockback(enemy.global_position - Vector3(sin(moveDir), 0, cos(moveDir)), dodgeVel.length(), true, lungeEffectiveness)
			if(dauntless && newKnockback):
				enemy.damage_taken(4 * cowDamageMod, "player", false)
			justKnocked.append(enemy)
			camera.add_trauma(0.3)
			knocked = true
#			Vocal.volume_db = volume

func updateHealth(newHP:float):
	if(newHP < hitpoints && newHP < maxHitpoints):
		if(russelOrRay == "Russel"):
			Vocal.stream = damagesound
			if(!Vocal.playing):
				Vocal.play()
		if(russelOrRay == "Ray"):
			Vocal.stream = RayHurtSound
			if(!Vocal.playing):
				Vocal.play()
	var increased = newHP > hitpoints
	hitpoints = newHP
	MainHud._on_health_update_(hitpoints / maxHitpoints)
	#healthCounter.updateHealth(hitpoints)
	if(healthPulse != null):
		var healthRatio = hitpoints / maxHitpoints
		if(healthRatio < 0.5):
			healthPulseIntensity = lerpf(healthPulseIntensity, 1.2 - healthRatio, 0.3)
			healthPulse.set_shader_parameter("intensity", healthPulseIntensity)
		elif(increased):
			resetHealthPulse = true
	if(hitpoints <= 0 and !invincible):
		die()
	if(hitpoints > maxHitpoints):
		hitpoints = maxHitpoints

func damage_taken(damage:float, from:String, _inCritHit:bool = false, _inBullet:Node = null) -> bool:
	if(from != "player"):
#		print("player damaged")
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
	if(dead):
		return
	dead = true
	lineSightNode.visible = false
	active = false
	animation.set("parameters/Death/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	var terrain = get_node("../AllTerrain")
	if(terrain.real):
		deathTimer = 3.0
		#if(russelOrRay == "Ray"):
		#	deathTimer = 2.5
		if(deathMenu == null):
			deathMenu = $"../DeathMenu"
		deathMenu.start()
		var level = get_node(NodePath("/root/Level"))
		level.changeMusic(4)
		var thieves = 0
		var enemies = get_tree().get_nodes_in_group("Enemy")
		for i in enemies:
			if(i.marauderType == 1):
				i.currentMode = 2
			elif(i.draggedCow != null || (i.currentMode != 7 && i.currentMode != 2)):
				thieves += 1
		for i in herd.getNumCows():
			thieves -= 1
			if(thieves <= 0):
				terrain.spawnMarauder(false)
	else:
		await Fade.fade_out(3).finished
		resetHealthPulse = true
		animation.set("parameters/DeathTime/scale", 1.5)
		position = checkpoint
		updateHealth(maxHitpoints)
		var cows = herd.getCows()
		for i in cows:
			i.delete()
		if(checkpointCowAmmount <= 0 && !canHaveNoCows):
			checkpointCowAmmount = 1
		for i in checkpointCowAmmount:
			herd.spawnCowAtPos(Vector3(position.x + (rng.randf() - 0.5), position.y, position.z + (rng.randf() - 0.5)), 0)
		deathTimer = 0
		dead = false
		active = true
		Fade.fade_in()
	# all possible bones #var phys_bones = ["Hips", "Spine", "Spine 1", "Spine2", "Neck", "LeftShoulder", "LeftArm", "leftForeArm", "LeftHand", "RightShoulder", "RightArm", "RightForeArm", "RightUpLeg", "LeftFoot", "RightFoot"]
	#testing individual bones #var phys_bones = ["LeftHand", "RightHand"]
#	rotation.x = PI / 2.0 
#	animation.set("parameters/idleWalk/blend_amount", 0)
#	animation.set("parameters/walkShoot/blend_amount", 0.1)
#	animation.set("parameters/shootAngle/blend_position", 1)
	#skeleton.physical_bones_start_simulation(phys_bones)
