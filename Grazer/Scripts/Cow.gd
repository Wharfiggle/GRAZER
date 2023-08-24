#Elijah Southman

extends CharacterBody3D

@export var normalSpeed = 8.0
@export var normalLookSpeed = 3.0
@export var normalFollowDistance = 2.0
var followDistance = normalFollowDistance
var targetRandOffset = 0.0
@export var pushStrength = 60.0
@export var pushDistanceThreshold = 1.5
var pushVel = Vector2(0, 0)
@export var normalSpeedTransitionRadius = 1.5
var speedTransitionRadius = normalSpeedTransitionRadius
@export var shuffleTime = 0.7
@export var shuffleTimeRandOffset = 0.3
@export var shuffleStrength = 0.75
@export var shuffleSpeed = 3.0
var shuffleTimeCounter = 0
@export var dragSpeed = 7.0
@export var dragLookSpeed = 2.0
@export var dragShake = 0.05
@export var dragFollowDistance = 1.0
@export var dragSpeedTransitionRadius = 0.1
@export var draggers = []
func getNumDraggers(): return draggers.size() #Used in Herd.getClosestCow()
var dragShakeOffset = 0
@export var maneuverTurnSpeed = 5.0
@export var maneuverMoveSpeed = 0.7
var maneuverTurnOffset = 0
var maneuverMoveModifier = 0
var maneuvering = false
var maneuverTurnDir = 1
@onready var rayCasts = [
	#get_node(NodePath("./RayCastSideLeft")),
	get_node(NodePath("./RayCastLeft")), 
	get_node(NodePath("./RayCastMiddle")), 
	get_node(NodePath("./RayCastRight"))]
	#get_node(NodePath("./RayCastSideRight")),
	#get_node(NodePath("./RayCastDirect"))]
var raySize = [2.0, 1.0, 2.0]

var animationBlend = 0
var herd
var tVelocity = Vector3(0, 0, 0)
var speed = 0.0
var rng = RandomNumberGenerator.new()
var follow = true
var followingHerd = false
var huddling = false
var target
var maxSpeed = normalSpeed
var lookSpeed = normalLookSpeed
#export (float) var accelerationModifier = 0.1
#export (float) var accelerationDampening = 40.0
#export (float) var accDampRandOffset = 20.0
#var acceleration = 0.0
#export (float) var minPushDistance = 0.0
#export (float) var minPushPercent = 0.0
#export (float) var lookMoveDissonance = 0.0
var isDragged = false
#AudioStreams
@onready var Steps = $walking
@onready var Vocal = $moo
@onready var vocalVol = Vocal.volume_db
#SoundFiles PreLoad
var stressed = preload("res://sounds/Cows/Cows/cowstressed.wav")
var moos = [preload("res://sounds/Cows/Cows/idlemoo1.wav"),
preload("res://sounds/Cows/Cows/idlemoo2.wav"),
preload("res://sounds/Cows/Cows/idlemoo3.wav")]
var moo = null
#var audioArray = [moo1,moo2,moo3]
@onready var hitFlash = get_node(NodePath("./Model/CowBones/Skeleton3D/Cow")).get_material_override()

var model = null
var animation = null
var skeleton = null
var potionSpeedup = 1.0
var dragResistance = 1.0
var cowTypeInd = -1

var gravity = 30
var hibernate = false
@onready var terrain = get_node("/root/Level/AllTerrain")
@onready var level = get_node("/root/Level")
var speedBoostTimer = 0

var uiSelectMode = -1
var uiSelectTimeCounter = 0

var stray = false

var offscreenIndicator = null
@export var mooIndicatorTime = 3.0
var mooIndicatorTimer = 0
var redPulseTime = 0
@export var mooBaseTime = 15.0
@export var mooVariantTime = 10.0
var mooTime = 0.0
var mooTimer = 0.0
@onready var camera = get_node(NodePath("/root/Level/Camera3D"))

var fallTimer = 0
var startFallY = 0

var stealingIconVisible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Vocal.volume_db = 2.0
	
	rng.randomize()
	#accelerationDampening = rng.randf_range(accelerationDampening - accDampRandOffset, accelerationDampening + accDampRandOffset)
	#accelerationModifier = rng.randf_range(accelerationModifier - 0.05, accelerationDampening + 0.05)
	shuffleTime = rng.randf_range(
		shuffleTime - shuffleTimeRandOffset, 
		shuffleTime + shuffleTimeRandOffset)
	targetRandOffset = rng.randf_range(-targetRandOffset, targetRandOffset)
	
	mooTime = rng.randf_range(
		mooBaseTime - mooVariantTime,
		mooBaseTime + mooVariantTime)
	mooTimer = mooTime
	
	moo = moos[rng.randi_range(0, moos.size() - 1)]
	
	#var phys_bones = ["Tail_1", "Ear_Upper_r", "Ear_Upper_l"]
	#var phys_bones = ["Tail_1"]
	#var phys_bones = ["Tail_1", "Ear_Base_r", "Ear_Base_l"]
	#skeleton.physical_bones_start_simulation(phys_bones)
	#skeleton.physical_bones_start_simulation()
	
	animation.set("parameters/conditions/Drag", false)
	animation.set("parameters/conditions/Not_Drag", true)
	animation.set("parameters/conditions/Graze", false)
	animation.set("parameters/conditions/Not_Graze", true)
	#get_node(NodePath("./Model/AnimationPlayer")).set_speed(10.0)
	
	if(cowTypeInd == -1):
		setType()
	
func makeMoo():
	Vocal.stream = moo
	Vocal.play()
	
func setType(ind:int = -1):
	model = get_node(NodePath("./Model"))
	animation = model.find_child("AnimationTree")
	skeleton = model.find_child("Skeleton3D")
	var mesh = model.find_child("Cow")
	var material = mesh.get_material_overlay()
	var typeTextures = [
		preload("res://Assets/Models/Cow/cowCommon.png"),
		preload("res://Assets/Models/Cow/cowRed.png"),
		preload("res://Assets/Models/Cow/cowLucky.png"),
		preload("res://Assets/Models/Cow/cowGrandRed2.png"),
		preload("res://Assets/Models/Cow/cowIronhide.png"),
		preload("res://Assets/Models/Cow/cowMoxie2.png")]
	
	#set cow texture based on cow type
	if(ind == -1):
		cowTypeInd = rng.randi_range(0, typeTextures.size() - 1)
	else:
		cowTypeInd = ind
	var typeMaterial = material.duplicate()
	typeMaterial.set_texture(StandardMaterial3D.TEXTURE_ALBEDO, typeTextures[cowTypeInd])
	mesh.set_material_overlay(typeMaterial)
	#randomly set cow horn type
	match rng.randi_range(0, 4):
		0: mesh.set("blend_shapes/Back", 1)
		1: mesh.set("blend_shapes/Down", 1)
		2: mesh.set("blend_shapes/Out", 1)
		3: mesh.set("blend_shapes/Way Out", 1)
		4: mesh.set("blend_shapes/Down", 0)
	

func setHibernate(inHibernate:bool):
	#hijack to teleport cow back to edge of screen
	hibernate = inHibernate
	if(hibernate):
		gravity = 0
		position.y = 0
	else:
		gravity = 30

func startDragging(marauder):
	isDragged = true
	draggers.append(marauder)
	maxSpeed = min(dragSpeed * draggers.size(), draggers[0].baseSpeed) / dragResistance
	lookSpeed = dragLookSpeed * draggers.size()
	followDistance = dragFollowDistance
	speedTransitionRadius = dragSpeedTransitionRadius
	#while(isDragged):
		#if(!Vocal.is_playing()):
	Vocal.stream = stressed
	Vocal.play()
	
	herd.removeHuddler(self)
	#Set to disable, because otherwise the cow can't look at the marauder when dragged
	#disableRayCasts() dont do this, it completely breaks all maneuvering. i fixed the collision layers so they dont look away from the marauders
	animation.set("parameters/conditions/Drag", true)
	animation.set("parameters/conditions/Not_Drag", false)
	
func stopDragging(marauder):
	Vocal.stop()
	isDragged =false
	draggers.erase(marauder)
	marauder.draggedCow = null
	if(draggers.size() == 0):
		maxSpeed = normalSpeed
		lookSpeed = normalLookSpeed
		followDistance = normalFollowDistance
		speedTransitionRadius = normalSpeedTransitionRadius
	animation.set("parameters/conditions/Drag", false)
	animation.set("parameters/conditions/Not_Drag", true)
	
func enableRayCasts():
	for i in rayCasts:
		i.enabled = true
	
func disableRayCasts():
	for i in rayCasts:
		i.enabled = false

#called by herd when cow is removed from herd
func idle():
	disableRayCasts()
	follow = false
	target = null
	followingHerd = false
	animation.set("parameters/Movement/BlendMove/blend_amount", -1)
	#var clip_to_play = audioArray[randi() % audioArray.size()] 
	#Vocal.stream=clip_to_play
	#Vocal.play()

#equation for diagonal length of screen
#var rectWid = 15 / cos(55 * PI / 180)
#var rectHei = 15 / 9 * 16
#var rectDiag = rectWid / sin( arctan( rectWid / rectHei )

func damage_taken(_damage:float, from:String, _inCritHit:bool = false, bullet:Node = null) -> bool:
	if(from == "player" && !draggers.is_empty()):
		return false
	else:
		if(bullet != null):
			bullet.bulletStopExtend = 0.5
		return true

func delete():
	if(herd != null):
		herd.removeCow(self)
	else:
		herd = get_node("/root/Level/Herd")
		if(herd != null):
			herd.removeCow(self)
		else:
			push_error("could not find herd to remove deleted cow from")
	if(offscreenIndicator != null):
		offscreenIndicator.queue_free()
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
#	if(Input.is_action_just_pressed("shoot")):
#		mooIndicatorTimer = mooIndicatorTime
	
	if(mooTimer > 0):
		mooTimer -= delta
		if(mooTimer < 0):
			mooTimer = 0
			if(stray):
				makeMoo()
				mooTime = rng.randf_range(
				mooBaseTime - mooVariantTime,
				mooBaseTime + mooVariantTime)
				mooTimer = mooTime
				mooIndicatorTimer = mooIndicatorTime
	
	if(uiSelectMode != -1):
		uiSelectTimeCounter += delta
		var hitFlashAmount = abs( sin( uiSelectTimeCounter * 4) ) * 0.05
		if(uiSelectMode == 0):
			hitFlash.set_shader_parameter("color", Color.WHITE)
		if(uiSelectMode == 1):
			hitFlashAmount += 0.3
			hitFlash.set_shader_parameter("color", Color.CYAN)
		elif(uiSelectMode == 2):
			hitFlashAmount = 0.4
			hitFlash.set_shader_parameter("color", Color(0, 200/255.0, 110/255.0, 1))
		hitFlash.set_shader_parameter("amount", hitFlashAmount)
	else:
		hitFlash.set_shader_parameter("amount", 0)
	
	if(herd != null):
		if(target != null || !draggers.is_empty()):
			var targetVector
			if(!draggers.is_empty()):
				targetVector = Vector2.ZERO
				for i in draggers:
					targetVector += Vector2(
						i.position.x - position.x, 
						i.position.z - position.z)
				targetVector /= draggers.size()
			elif(target != null):
				targetVector = Vector2(target.x - position.x + targetRandOffset, target.y - position.z + targetRandOffset)
			
			if(Input.is_action_pressed("cowParty")):
				rotate_y(maxSpeed)
			elif(follow || !draggers.is_empty()):
				var targetAngle = atan2(targetVector.x, targetVector.y) + PI
				#var angDiff = abs(fmod((rotation.y + 2 * PI), 2 * PI) - targetAngle)
				#print(str(fmod((rotation.y + 2 * PI), 2 * PI)) + " and " + str(targetAngle))
				#print("diff: " + str(angDiff))
				#var targetDir = 1 #counter clockwise
				#if(angDiff < 2 * PI - angDiff):
				#	targetDir = -1 #clockwise
				#rotate away from objects detected in raycasts
				var rayInd = 0
				var rayMags = [0, 0, 0]
				for i in rayCasts:
					if(i == null):
						printerr("Cow.gd: null raycasts")
					elif(i.is_colliding()):
						#if(rayInd == 5):
						#	rayMags[rayInd] = 1
						#else:
							#from 0 to raySize[ind], 0: raySize[ind] meters away, 1: 0 meters away
							var t = 1 - (i.get_collision_point() - i.global_transform.origin).length() / raySize[rayInd]
							rayMags[rayInd] = pow(t, 2)
					rayInd += 1
				#if(rayMags[5] != 0): #direct
				if(rayMags[0] > 0.01 && rayMags[2] > 0.01): #left and right
					maneuverTurnOffset = maneuverTurnDir * (rayMags[0] + rayMags[2]) * maneuverTurnSpeed * delta
					maneuvering = true
					#maneuverMoveModifier = -abs(maneuverMoveModifier)
				elif(rayMags[0] > 0.01): #left
					maneuverTurnOffset = -rayMags[0] * maneuverTurnSpeed * delta
					if(maneuvering == false):
						maneuverTurnDir = -1
					maneuvering = true
					#maneuverMoveModifier = abs(maneuverMoveModifier)
				elif(rayMags[2] > 0.01): #right
					maneuverTurnOffset = rayMags[2] * maneuverTurnSpeed * delta
					if(maneuvering == false):
						maneuverTurnDir = 1
					maneuvering = true
					#maneuverMoveModifier = abs(maneuverMoveModifier)
				elif(rayMags[1] > 0.01): #middle
					maneuverTurnOffset = maneuverTurnDir * rayMags[1] * maneuverTurnSpeed * delta
					maneuvering = true
					#maneuverMoveModifier = abs(maneuverMoveModifier)
				else:
					#maneuverMoveModifier = abs(maneuverMoveModifier)
					maneuvering = false
				#elif(rayMags[0] > 0.01): #side left
				#	maneuverTurnOffset = -rayMags[0] * maneuverTurnSpeed * delta
				#elif(rayMags[4] > 0.01): #side right
				#	maneuverTurnOffset = rayMags[4] * maneuverTurnSpeed * delta
				#else:
				#	maneuvering = false
				#rayCasts[5].global_rotation = Vector3(0, 0, 0)
				#rayCasts[5].target_position = Vector3(targetVector.x, 0, targetVector.y)
				if(maneuvering == false):
					maneuverTurnOffset = lerp_angle(
						maneuverTurnOffset,
						0,
						delta)
				rotation.y += maneuverTurnOffset
				
				if(maneuvering == false):
					#look at target
					rotation.y = lerp_angle(
						rotation.y,
						targetAngle, 
						lookSpeed * delta)
						
				
				#Reducing movespeed until cow is facing right direction when dragged
				if(getNumDraggers() > 0):
					#Is in radians
					var curDirection = Vector2 (cos (rotation.y), sin (rotation.y))
					var targetDirection = Vector2 (cos (targetAngle), sin (targetAngle))
					#Use dot product to produce a scaler 0 < x < 1 based on the cow's direction
					maxSpeed = dragSpeed * ((curDirection.dot(targetDirection))) / dragResistance
					
				
			var targetDistance = followDistance
			if(followingHerd && draggers.is_empty()):
				#radius of herd
				targetDistance = sqrt( pow(pushDistanceThreshold, 2) * herd.numCows )
			var dist = sqrt( pow(targetVector.x, 2) + pow(targetVector.y, 2) )
			if(draggers.is_empty() && herd.canHuddle && dist <= targetDistance + 0.1 && huddling == false):
				herd.addHuddler(self)
				disableRayCasts()
				
			if(huddling == false && (follow || !draggers.is_empty())):
#				stopGraze()
				shuffleTimeCounter = 0
				#speedTransitionRadius meters FARTHER than targetDistance or more: speed
				#speedTransitionRadius meters CLOSER than targetDistance or more: -speed
				#interpolates between the two for all values in between
				speed = min( max( (dist - targetDistance) / speedTransitionRadius, 0 ), 1 ) * maxSpeed
				var mmoTargetValue = 1
				if(maneuverTurnOffset > 0.01 || maneuverTurnOffset < -0.01):
					mmoTargetValue = maneuverMoveSpeed
				maneuverMoveModifier = lerp(
					float(maneuverMoveModifier),
					float(mmoTargetValue),
					0.3)
				speed *= maneuverMoveModifier
				tVelocity.x = -sin(rotation.y) * speed
				tVelocity.z = -cos(rotation.y) * speed
				model.position.z = lerp(model.position.z, 0.0, 0.1)
				
				#old shuffle algorithm
				#var prevAcc = acceleration
				#acceleration = accelerationModifier * (dist - targetDistance)
				#if(acceleration < 0 && speed > 0):
				#	acceleration = max(acceleration * accelerationDampening, -speed)
				#if(acceleration > 0 && speed < 0):
				#	acceleration = min(acceleration * accelerationDampening, -speed)
				#speed += acceleration
				#speed = max(min(speed, maxSpeed), -maxSpeed)
			else:
				#cow's model shuffles before coming to a stop
				if(tVelocity.x != 0 || tVelocity.z != 0):
					tVelocity.x = 0
					tVelocity.z = 0
					shuffleTimeCounter = shuffleTime
				elif(shuffleTimeCounter > 0):
					shuffleTimeCounter -= delta
					if(shuffleTimeCounter < 0):
						shuffleTimeCounter = 0
#						graze()
					
					var startT = min(0.3, shuffleTime - shuffleTimeCounter) / 0.3
					#print(startT)
					model.position.z = startT * -sin(shuffleTimeCounter * shuffleSpeed) * shuffleStrength * ((shuffleTime - shuffleTimeCounter) / shuffleTime)
					#Normalize t to range between -1 and 1
					var t = (shuffleTimeCounter / shuffleTime)
					t = t * (animationBlend + 1 + startT) - 1
					if(t == -1):
						animationBlend = -1
					animation.set("parameters/Movement/BlendMove/blend_amount", t)
		elif(stray && abs((position - herd.player.position).length()) < 2.5):
			Vocal.volume_db = vocalVol
			herd.addCow(self, true)
			stray = false
			self.remove_from_group('DespawnAtCheckpoint')
		
		if(draggers.is_empty()):
			#cows push eachother out of eachother's radius
			var cows = herd.getCows()
			var avgVec = Vector2(0, 0)
			var numInside = 0
			for i in cows:
				if(i != self):
					#direction to other cow
					var cowDirVec = Vector2(
						position.x - i.position.x, 
						position.z - i.position.z)
					#distance to other cow
					var dist = sqrt(pow(cowDirVec.x, 2) + pow(cowDirVec.y, 2))
					if(dist < pushDistanceThreshold):
						#0 to 1, 0: pushDistanceThreshold meters away, 1: 0 meters away
						var t = min( max( (pushDistanceThreshold - dist) / pushDistanceThreshold, -1 ), 1 )
						numInside += 1
						#average push vector to every other cow with magnitude from 0 to 1
						avgVec += cowDirVec.normalized() * t
						
						#minPushDistance makes maximum push strength come at a distance of minPushDistance instead of 0, made pushing extremely jittery so I cut it
						#var t = min( max( (pushDistanceThreshold + minPushDistance - dist) / pushDistanceThreshold, -1 ), 1 )
						
						#makes t go from minPushPercent to 1 instead of 0 to 1, made pushing look a little jittery so I cut it
						#if(minPushPercent > 0):
						#	t = t * ( 1.0 - minPushPercent ) + minPushPercent
						
						#t = pow(t, 3)
						#dist = smoothstep(0, 1, dist)
			if(numInside > 1):
				avgVec /= numInside
			pushVel = avgVec * pushStrength
	else:
		herd = get_node("/root/Level/Herd")
		print("Cow.gd: herd is null")
		
	if(terrain != null):
		var chunk = terrainController.getPlayerChunk(position)
		setHibernate(!terrain.activeCoord.has(chunk))
	else:
		setHibernate(true)
		terrain = get_node("/root/Level/AllTerrain")
	
	speedBoostTimer -= delta
	if(speedBoostTimer < 0):
		speedBoostTimer = 0
	
	#limit total velocity to not go past maxSpeed
	var enemySpeedLimit = 1.0
	var speedBoost = 1.0
	if(draggers.is_empty()):
		if(level.currentMusic == 1):
			enemySpeedLimit = 0.65
			speedBoostTimer = 1.0
		elif(speedBoostTimer > 0):
			speedBoost = 1.5
	var totalVelocity = tVelocity + Vector3(pushVel.x, 0, pushVel.y)
	if(totalVelocity.length() > maxSpeed * enemySpeedLimit):
		totalVelocity = totalVelocity.normalized() * maxSpeed * enemySpeedLimit
	totalVelocity *= speedBoost
	
	#gravity, unnaffected by maxSpeed limit
	if(target != null):
		tVelocity.y -= gravity * delta
		if(is_on_floor()):
			tVelocity.y = -0.1
		elif(transform.origin.y < -20.0):
	#		transform.origin = Vector3(0, 10, 0)
			for i in draggers:
				if(i != null):
					stopDragging(i)
			herd.deleteCow(self)
			SceneCounter.cows -= 1
		totalVelocity.y = tVelocity.y
	else:
		tVelocity.y = 0
		totalVelocity.y = 0
	
	if(shuffleTimeCounter < 0.01 && shuffleTimeCounter > -0.01):
		#Normalize animationBlend to range between -1 and 1
		#Make negative for goblin mode
		animationBlend = Vector3(totalVelocity.x, 0, totalVelocity.z).length() / maxSpeed * 2 - 1
		animationBlend = min(max(animationBlend, -1), 1)
		animation.set("parameters/Movement/BlendMove/blend_amount", animationBlend)
	
	#apply velocity and move
	set_velocity(totalVelocity)
	if(draggers.is_empty()):
		set_velocity(totalVelocity * potionSpeedup)
	set_up_direction(Vector3.UP)
	move_and_slide()
	
	if(position.y < -0.01):
		if(fallTimer == 0):
			startFallY = position.y
		fallTimer += 1
		if(fallTimer > 10):
			if(abs(startFallY - position.y) < 0.1):
				position.y = 0
			fallTimer = 0
	else:
		fallTimer = 0
	
	var separated = !stray && draggers.is_empty() && follow #if cow goes offscreen, isn't a stray, and isn't being stolen, we want to teleport it back to the player on the edge of the screen.
	#section for calculating where the offscreen indicators should go on the edge of the screen
	if(( separated || !draggers.is_empty() || mooIndicatorTimer > 0 ) && offscreenIndicator != null && camera != null):
		#if cow is not being dragged and goes far enough off screen (indctrdff.length() > ~7) then teleport to where new indicator location would be (with edgeMargin = ~-2) and initiate enemy relocation procedure to see if it's a valid location
		var mooInd = offscreenIndicator.get_child(0)
		var stealInd = offscreenIndicator.get_child(1)
		
		var edgeMargin = 1.0
		if(separated): edgeMargin = -2.0
		var scrHei = camera.size #height of screen in meters
		var scrWid = scrHei / 9.0 * 16.0 #only works with 16:9 aspect ratio. screen ratio is fixed so its fine
		scrHei -= edgeMargin * 2
		scrWid -= edgeMargin * 2
		var wrldHei = scrHei / cos(55.0 * PI / 180.0) #height of world shown on screen due to camera pitch
		
		var bound1 = Vector2( #top left
			-scrWid / 2.0,
			-wrldHei / 2.0)
		var bound2 = -bound1 #bottom right
		#move down a bit to look better
		bound1.y += 1.0
		bound2.y += 1.0
		
		var healthCorner = Vector2(-7.5, -10.5)
		var gunCorner = Vector2(-8.5, 10)
		#var healthCorner = Vector2(0, 0)
		
		offscreenIndicator.global_position = global_position
		var indctr = offscreenIndicator.global_position - (camera.position - camera.camOffset)
		indctr = Vector2( #rotate by 45 degrees to compensate for camera angle yaw
			cos(PI/4.0) * indctr.x - sin(PI/4.0) * indctr.z,
			sin(PI/4.0) * indctr.x + cos(PI/4.0) * indctr.z)
		var clampedIndctr = Vector2( #clamp into screen bounds
			min(max(indctr.x, bound1.x), bound2.x),
			min(max(indctr.y, bound1.y), bound2.y))
		var indctrDiff = clampedIndctr - indctr
		
		if(indctrDiff.length() > 0): #offscreen
			if(!separated):
				if(clampedIndctr.x < healthCorner.x && clampedIndctr.y < healthCorner.y):
					if(abs(indctrDiff.x) > abs(indctrDiff.y)):
						indctrDiff.x += scrWid / 2.0 + healthCorner.x
					else:
						indctrDiff.y += wrldHei / 2.0 + healthCorner.y
				elif(clampedIndctr.x < gunCorner.x && clampedIndctr.y > gunCorner.y):
					if(abs(indctrDiff.x) > abs(indctrDiff.y)):
						indctrDiff.x += scrWid / 2.0 + gunCorner.x
					else:
						indctrDiff.y -= wrldHei / 2.0 - gunCorner.y
				
			indctrDiff = Vector2( #rotate back
				cos(-PI/4.0) * indctrDiff.x - sin(-PI/4.0) * indctrDiff.y,
				sin(-PI/4.0) * indctrDiff.x + cos(-PI/4.0) * indctrDiff.y)
				
			offscreenIndicator.global_position += Vector3(indctrDiff.x, 0, indctrDiff.y)
			if(separated && indctrDiff.length() > 8):
				global_position = offscreenIndicator.global_position
				print("cow teleport back to player")
			elif(!stray):
				mooInd.visible = true
				stealInd.visible = true
				stealingIconVisible = true
		elif(!stray): #not offscreen
			mooInd.visible = false
			stealInd.visible = false
			stealingIconVisible = false
			
		var maxDist = 50.0
		if(mooIndicatorTimer > 0):
			maxDist = 100.0
		var size = max(0.5, 1.0 - (indctrDiff.length() / maxDist))
		offscreenIndicator.scale = Vector3(size, size, size)
			
		if(mooIndicatorTimer > 0):
			mooIndicatorTimer -= delta
			var mooMat = mooInd.get_surface_override_material(0).duplicate()
			if(mooIndicatorTimer < 0):
				mooIndicatorTimer = 0
				mooInd.visible = false
				mooMat.albedo_color = Color(1, 0, 0, 1)
			else:
				mooInd.visible = true
				var t = 0
				if(mooIndicatorTimer > mooIndicatorTime / 2.0): 
					t = 1.0 - (mooIndicatorTimer - mooIndicatorTime / 2.0) / (mooIndicatorTime / 2.0)
				else:
					t = mooIndicatorTimer / (mooIndicatorTime / 2.0)
				mooMat.albedo_color = Color(1, 1, 1, sqrt(t))
			mooInd.set_surface_override_material(0, mooMat)
		else:
			redPulseTime += delta
			size = (1.0 / size) * 0.5 + abs(sin(redPulseTime * 5))
			mooInd.scale = Vector3(size, size, size) / 2.0
			
#		var fromCenter = global_position - (camera.position - camera.camOffset)
#		fromCenter.y = 0
#		var radx = bound1.x
#		var rady = bound1.y
#		var toEdge = Vector3(fromCenter.normalized().x * radx, 0, fromCenter.normalized().y * rady)
#		if(fromCenter.length() < toEdge.length()):
#			offscreenIndicator.global_position = toEdge
	elif(offscreenIndicator == null):
		offscreenIndicator = find_child("OffscreenIndicator")
		if(offscreenIndicator != null):
			self.remove_child(offscreenIndicator)
			get_node(NodePath("/root/Level")).add_child(offscreenIndicator)
			var indMat = offscreenIndicator.get_child(1).get_surface_override_material(0).duplicate()
			match(cowTypeInd):
				0: indMat.albedo_color = Color(194.0 / 255.0, 181.0 / 255.0, 155.0 / 255.0)
				1: indMat.albedo_color = Color(206.0 / 255.0, 73.0 / 255.0, 70.0 / 255.0)
				2: indMat.albedo_color = Color(218.0 / 255.0, 200.0 / 255.0, 86.0 / 255.0)
				3: indMat.albedo_color = Color(218.0 / 255.0, 47.0 / 255.0, 39.0 / 255.0)
				4: indMat.albedo_color = Color(94.0 / 255.0, 132.0 / 255.0, 141.0 / 255.0)
				5: indMat.albedo_color = Color(171.0 / 255.0, 108.0 / 255.0, 173.0 / 255.0)
			offscreenIndicator.get_child(1).set_surface_override_material(0, indMat)
			print("cow type " + str(cowTypeInd))
	elif(camera == null):
		camera = get_node(NodePath("/root/Level/Camera3D"))
	else:
		#everything is set as it should be, but no conditions for calculating offscreen indicators are true
		offscreenIndicator.get_child(0).visible = false
		offscreenIndicator.get_child(1).visible = false
	
	#make cow's model look in the direction it's moving
	if((totalVelocity.x > 0.01 || totalVelocity.x < -0.01 
	|| totalVelocity.z > 0.01 || totalVelocity.z < -0.01)
	&& !huddling):
		model.rotation.y -= dragShakeOffset
		var moveDirection = atan2(totalVelocity.x, totalVelocity.z) + PI
		#print(str(model.rotation.y) + " and " + str(rotation.y))
		model.rotation.y = lerp_angle(
			model.rotation.y,
			moveDirection - rotation.y, 
			lookSpeed * delta)
		if(!draggers.is_empty()):
			dragShakeOffset = rng.randf_range(-dragShake, dragShake)
			model.rotation.y += dragShakeOffset
		else:
			dragShakeOffset = 0
		
	else: #make cow model's rotation go back to 0
		model.rotation.y = lerp_angle(
			model.rotation.y, 
			0, 
			lookSpeed * delta)
	#old attempt to make cows look where they're moving
	#if(totalVelocity != Vector3.ZERO && lookMoveDissonance != 0):
	#	var moveDirection = atan2(totalVelocity.x, totalVelocity.z)
	#	var dissRad = lookMoveDissonance * 180.0 / PI
	#	rotation.y = moveDirection + min(max(moveDirection - rotation.y, -dissRad), dissRad)

func graze():
	animation.set("parameters/conditions/Graze", true)
	animation.set("parameters/conditions/Not_Graze", false)
func stopGraze():
	animation.set("parameters/conditions/Graze", false)
	animation.set("parameters/conditions/Not_Graze", true)
