#Elijah Southman

extends KinematicBody

export (float) var normalSpeed = 9.0
#export (float) var accelerationModifier = 0.1
#export (float) var accelerationDampening = 40.0
#export (float) var accDampRandOffset = 20.0
export (float) var normalLookSpeed = 2.0
#export (float) var lookMoveDissonance = 0.0
export (float) var followDistance = 3.0
export (float) var pushStrength = 60.0
export (float) var pushDistanceThreshold = 2.0
#export (float) var minPushDistance = 0.0
#export (float) var minPushPercent = 0.0
var pushVel = Vector2(0, 0)
export (float) var speedTransitionRadius = 1.5
export (float) var shuffleTime = 0.7
export (float) var shuffleTimeRandOffset = 0.5
export (float) var shuffleStrength = 0.75
export (float) var shuffleSpeed = 3.0
var shuffleTimeCounter = 0
export (float) var dragSpeed = 5.0
export (float) var dragLookSpeed = 1.0
export (float) var dragShake = 0.1
var dragger = null
var dragShakeOffset = 0
export (float) var maneuverTurnSpeed = 2.0
onready var rayCasts = [
	get_node(NodePath("./RayCastLeft")), 
	get_node(NodePath("./RayCastMiddle")), 
	get_node(NodePath("./RayCastRight"))]
var raySize = [2.0, 4.0, 2.0]
var maneuverOffset = 0
var maneuvering = false
onready var model = get_node(NodePath("./Model"))
var herd
var velocity = Vector3(0, 0, 0)
var speed = 0.0
#var acceleration = 0.0
var rng = RandomNumberGenerator.new()
var follow = true
var followingHerd = false
var huddling = false
var target
var maxSpeed = normalSpeed
var lookSpeed = normalLookSpeed

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	#accelerationDampening = rng.randf_range(accelerationDampening - accDampRandOffset, accelerationDampening + accDampRandOffset)
	#accelerationModifier = rng.randf_range(accelerationModifier - 0.05, accelerationDampening + 0.05)
	shuffleTime = rng.randf_range(
		shuffleTime - shuffleTimeRandOffset, 
		shuffleTime + shuffleTimeRandOffset)

func startDragging(marauder):
	dragger = marauder
	maxSpeed = dragSpeed
	lookSpeed = dragLookSpeed
	herd.removeHuddler(self)
	
func stopDragging():
	dragger = null
	maxSpeed = normalSpeed
	lookSpeed = normalLookSpeed
	
func enableRayCasts():
	for i in rayCasts:
		i.enabled = true
	
func disableRayCasts():
	for i in rayCasts:
		i.enabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(herd != null):
		if(target != null || dragger != null):
			var targetVector
			if(dragger != null):
				targetVector = Vector2(
					translation.x - dragger.translation.x, 
					translation.z - dragger.translation.z)
			elif(target != null):
				targetVector = Vector2(translation.x - target.x, translation.z - target.y)
			
			if(Input.is_action_pressed("cowParty")):
				rotate_y(maxSpeed)
			elif(follow || (dragger != null)):
				var targetAngle = atan2(targetVector.x, targetVector.y)
				#counter clockwise
				var targetAngleDir = 1
				if(targetAngle + PI < rotation.y + PI):
					#clockwise
					targetAngleDir = -1
				
				#rotate away from objects detected in raycasts
				var rayInd = 0
				var rayMags = [0, 0, 0]
				for i in rayCasts:
					if(i == null):
						printerr("Cow.gd: null raycasts oggofosodfodofsdfo!")
					elif(i.is_colliding()):
						var collision = i.get_collision_point()
						var t = 1.0 - (collision - i.global_translation).length() / raySize[rayInd] #divide by length of rayCast
						rayMags[rayInd] = 1 + pow(t, 2)
					rayInd += 1
				if(rayMags[1] != 0 || maneuvering): #middle
					maneuvering = true
					if(rayMags[0] != 0 && rayMags[2] != 0): #left and right
						maneuverOffset = (rayMags[0] + rayMags[2]) / 2.0 * maneuverTurnSpeed * delta
					elif(rayMags[0] != 0): #left
						maneuverOffset = -rayMags[0] * maneuverTurnSpeed * delta
					elif(rayMags[2] != 0): #right
						maneuverOffset = rayMags[2] * maneuverTurnSpeed * delta
					elif(rayMags[1] != 0): #just middle
						maneuverOffset = rayMags[1] * maneuverTurnSpeed * delta * targetAngleDir
					else: #none
						maneuvering = false
				if(maneuvering == false):
					maneuverOffset = lerp_angle(
						maneuverOffset,
						0,
						lookSpeed * delta)
				rotation.y += maneuverOffset
				
				if(maneuvering == false):
					#look at target
					rotation.y = lerp_angle(
						rotation.y,
						targetAngle, 
						lookSpeed * delta)
			var targetDistance = followDistance
			if(followingHerd && dragger == null):
				#radius of herd
				targetDistance = sqrt( pow(pushDistanceThreshold, 2) * herd.numCows )
			var dist = sqrt( pow(targetVector.x, 2) + pow(targetVector.y, 2) )
			if(dragger == null && herd.canHuddle && dist < targetDistance && huddling == false):
				herd.addHuddler(self)
				disableRayCasts()
				
			if(huddling == false && (follow || dragger != null)):
				#speedTransitionRadius meters FARTHER than targetDistance or more: speed
				#speedTransitionRadius meters CLOSER than targetDistance or more: -speed
				#interpolates between the two for all values in between
				speed = min( max( (dist - targetDistance) / speedTransitionRadius, -1 ), 1 ) * maxSpeed
				velocity.x = -sin(rotation.y) * speed
				velocity.z = -cos(rotation.y) * speed
				model.translation.z = lerp(model.translation.z, 0, 0.1)
				
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
				if(velocity.x != 0 || velocity.z != 0):
					velocity.x = 0
					velocity.z = 0
					shuffleTimeCounter = 0
				elif(shuffleTimeCounter < shuffleTime):
					shuffleTimeCounter += delta
					model.translation.z = -sin(shuffleTimeCounter * shuffleSpeed) * shuffleStrength * ((shuffleTime - shuffleTimeCounter) / shuffleTime)
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
					translation.x - i.translation.x, 
					translation.z - i.translation.z)
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
	var totalVelocity = velocity + Vector3(pushVel.x, 0, pushVel.y)
	if(totalVelocity.length() > maxSpeed):
		totalVelocity = totalVelocity.normalized() * maxSpeed
	
	#gravity, unnaffected by maxSpeed limit
	velocity.y -= 30 * delta
	if(is_on_floor()):
		velocity.y = -0.1
	elif(transform.origin.y < -20.0):
		transform.origin = Vector3(0, 10, 0)
	totalVelocity.y = velocity.y
	
	#apply velocity and move
	move_and_slide(totalVelocity, Vector3.UP)
	
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
		if(dragger != null):
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
