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
@export var dragSpeed = 5.5
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
#SoundFiles PreLoad
var stressed = preload("res://sounds/Cows/Cows/cowstressed.wav")
var moo1 = preload("res://sounds/Cows/Cows/idlemoo1.wav")
var moo2 = preload("res://sounds/Cows/Cows/idlemoo2.wav")
var moo3 = preload("res://sounds/Cows/Cows/idlemoo3.wav")
var audioArray = [moo1,moo2,moo3]
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

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	#accelerationDampening = rng.randf_range(accelerationDampening - accDampRandOffset, accelerationDampening + accDampRandOffset)
	#accelerationModifier = rng.randf_range(accelerationModifier - 0.05, accelerationDampening + 0.05)
	shuffleTime = rng.randf_range(
		shuffleTime - shuffleTimeRandOffset, 
		shuffleTime + shuffleTimeRandOffset)
	targetRandOffset = rng.randf_range(-targetRandOffset, targetRandOffset)
	
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
	var clip_to_play = audioArray[randi() % audioArray.size()] 
	Vocal.stream=clip_to_play
	Vocal.play()
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(Input.is_action_just_pressed("jump")):
		graze()
	
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
					
					var startT = min(0.3, shuffleTime - shuffleTimeCounter) / 0.3
					#print(startT)
					model.position.z = startT * -sin(shuffleTimeCounter * shuffleSpeed) * shuffleStrength * ((shuffleTime - shuffleTimeCounter) / shuffleTime)
					#Normalize t to range between -1 and 1
					var t = (shuffleTimeCounter / shuffleTime)
					t = t * (animationBlend + 1 + startT) - 1
					if(t == -1):
						animationBlend = -1
					animation.set("parameters/Movement/BlendMove/blend_amount", t)
		else:
			if(abs((position - herd.player.position).length()) < 2.5):
				herd.addCow(self, true)
		
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
		
	var chunk = terrainController.getPlayerChunk(position)
	setHibernate(!terrain.activeCoord.has(chunk))
	
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
			herd.removeCow(self)
			queue_free()
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
	maxSpeed = 0
