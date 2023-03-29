#Elijah Southman

extends CharacterBody3D

@export var normalSpeed = 7.0
@export var normalLookSpeed = 3.0
@export var normalFollowDistance = 5.0
@export var dragFollowDistance = 1.0
var followDistance = normalFollowDistance
@export var pushStrength = 60.0
@export var pushDistanceThreshold = 1.5
var pushVel = Vector2(0, 0)
@export var speedTransitionRadius = 1.5
@export var shuffleTime = 0.7
@export var shuffleTimeRandOffset = 0.5
@export var shuffleStrength = 0.75
@export var shuffleSpeed = 3.0
var shuffleTimeCounter = 0
@export var dragSpeed = 5.0
@export var dragLookSpeed = 1.0
@export var dragShake = 0.05
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
@onready var model = get_node(NodePath("./Model"))
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

#AudioStreams
@onready var Steps = $walking
@onready var Vocal = $moo
#SoundFiles PreLoad

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	#accelerationDampening = rng.randf_range(accelerationDampening - accDampRandOffset, accelerationDampening + accDampRandOffset)
	#accelerationModifier = rng.randf_range(accelerationModifier - 0.05, accelerationDampening + 0.05)
	shuffleTime = rng.randf_range(
		shuffleTime - shuffleTimeRandOffset, 
		shuffleTime + shuffleTimeRandOffset)

func startDragging(marauder):
	draggers.append(marauder)
	maxSpeed = dragSpeed * draggers.size()
	lookSpeed = dragLookSpeed * draggers.size()
	followDistance = dragFollowDistance
	herd.removeHuddler(self)
	enableRayCasts()
	
func stopDragging(marauder):
	draggers.erase(marauder)
	if(draggers.size() == 0):
		maxSpeed = normalSpeed
		lookSpeed = normalLookSpeed
		followDistance = normalFollowDistance
	
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
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
				targetVector = Vector2(target.x - position.x, target.y - position.z)
			
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
						printerr("Cow.gd: null raycasts oggofosodfodofsdfo!") #you heard me
					elif(i.is_colliding()):
						#if(rayInd == 5):
						#	rayMags[rayInd] = 1
						#else:
							#from 0 to raySize[ind], 0: raySize[ind] meters away, 1: 0 meters away
							var t = 1 - (i.get_collision_point() - i.global_transform.origin).length() / raySize[rayInd]
							rayMags[rayInd] = pow(t, 2)
					rayInd += 1
				#if(rayMags[5] != 0): #direct
				maneuvering = true
				if(rayMags[0] > 0.01 && rayMags[2] > 0.01): #left and right
					maneuverTurnOffset = maneuverTurnDir * (rayMags[0] + rayMags[2]) / 2.0 * maneuverTurnSpeed * delta
					#maneuverMoveModifier = -abs(maneuverMoveModifier)
				elif(rayMags[0] > 0.01): #left
					maneuverTurnOffset = -rayMags[0] * maneuverTurnSpeed * delta
					maneuverTurnDir = -1
				elif(rayMags[2] > 0.01): #right
					maneuverTurnOffset = rayMags[2] * maneuverTurnSpeed * delta
					maneuverTurnDir = 1
				elif(rayMags[1] > 0.01): #middle
					maneuverTurnOffset = maneuverTurnDir * rayMags[1] * maneuverTurnSpeed * delta
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
			var targetDistance = followDistance
			if(followingHerd && draggers.is_empty()):
				#radius of herd
				targetDistance = sqrt( pow(pushDistanceThreshold, 2) * herd.numCows )
			var dist = sqrt( pow(targetVector.x, 2) + pow(targetVector.y, 2) )
			if(draggers.is_empty() && herd.canHuddle && dist < targetDistance && huddling == false):
				herd.addHuddler(self)
				disableRayCasts()
				
			if(huddling == false && (follow || !draggers.is_empty())):
				#speedTransitionRadius meters FARTHER than targetDistance or more: speed
				#speedTransitionRadius meters CLOSER than targetDistance or more: -speed
				#interpolates between the two for all values in between
				speed = min( max( (dist - targetDistance) / speedTransitionRadius, -1 ), 1 ) * maxSpeed
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
					shuffleTimeCounter = 0
				elif(shuffleTimeCounter < shuffleTime):
					shuffleTimeCounter += delta
					model.position.z = -sin(shuffleTimeCounter * shuffleSpeed) * shuffleStrength * ((shuffleTime - shuffleTimeCounter) / shuffleTime)
		else:
			print("Cow.gd: target is null")
		
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
		print("Cow.gd: herd is null")
		
	#limit total velocity to not go past maxSpeed
	var totalVelocity = tVelocity + Vector3(pushVel.x, 0, pushVel.y)
	if(totalVelocity.length() > maxSpeed):
		totalVelocity = totalVelocity.normalized() * maxSpeed
	
	#gravity, unnaffected by maxSpeed limit
	tVelocity.y -= 30 * delta
	if(is_on_floor()):
		tVelocity.y = -0.1
	elif(transform.origin.y < -20.0):
		transform.origin = Vector3(0, 10, 0)
	totalVelocity.y = tVelocity.y
	
	#apply velocity and move
	set_velocity(totalVelocity)
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
