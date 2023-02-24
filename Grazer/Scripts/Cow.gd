extends KinematicBody

export (float) var maxSpeed = 9.0
#export (float) var accelerationModifier = 0.1
#export (float) var accelerationDampening = 40.0
#export (float) var accDampRandOffset = 20.0
export (float) var lookSpeed = 2.0
export (float) var lookMoveDissonance = 0
export (float) var followDistance = 3.0
export (float) var pushStrength = 60.0
export (float) var pushDistanceThreshold = 1.75
export (float) var minPushDistance = 0.0
export (float) var minPushPercent = 0.0
export (float) var speedTransitionRadius = 1.5
export (int) var shuffleFrames = 40
export (int) var shuffleFramesRandOffset = 30
export (int) var shuffleFrameCounter = 0
export (float) var shuffleStrength = 0.75
export (float) var shuffleSpeed = 3.0
onready var model = get_node(NodePath("./Model"))
var shuffleTime = 0
var herd
var velocity = Vector3(0, 0, 0)
var speed = 0.0
var acceleration = 0.0
var rng = RandomNumberGenerator.new()
var follow = true
var followingHerd = false
var pushVel = Vector2(0, 0)
var huddling = false
var target

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	#accelerationDampening = rng.randf_range(accelerationDampening - accDampRandOffset, accelerationDampening + accDampRandOffset)
	#accelerationModifier = rng.randf_range(accelerationModifier - 0.05, accelerationDampening + 0.05)
	shuffleFrames = rng.randf_range(
		shuffleFrames - shuffleFramesRandOffset, 
		shuffleFrames + shuffleFramesRandOffset)

#func dragCow(marauder) -> Node:
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	shuffleTime += delta
	if(herd != null):
		if(target != null):
			var targetVector = Vector2(translation.x - target.x, translation.z - target.y)
			
			if(Input.is_action_pressed("cowParty")):
				rotate_y(maxSpeed)
			else:
				#look at player
				rotation.y = lerp_angle(
					rotation.y, 
					atan2(targetVector.x, targetVector.y), 
					lookSpeed * delta)
			var targetDistance = followDistance
			if(followingHerd):
				#radius of herd
				targetDistance = sqrt( pow(pushDistanceThreshold, 2) * herd.numCows )
			var dist = sqrt( pow(targetVector.x, 2) + pow(targetVector.y, 2) )
			if(herd.canHuddle && dist < targetDistance && huddling == false):
				huddling = true
				herd.addHuddler(self)
			#elif(dist > targetDistance * 2 && huddling == true):
				#huddling = false
				#herd.removeHuddler(self)
			if(huddling == false && follow):
				#speedTransitionRadius meters FARTHER than targetDistance or more: speed
				#speedTransitionRadius meters CLOSER than targetDistance or more: -speed
				#interpolates between the two for all values in between
				speed = min( max( (dist - targetDistance) / speedTransitionRadius, -1 ), 1 ) * maxSpeed
				velocity.x = -sin(rotation.y) * speed
				velocity.z = -cos(rotation.y) * speed
				model.translation.z = lerp(model.translation.z, 0, 0.1)
				
				#UNUSED old shuffle algorithm
				#var prevAcc = acceleration
				#acceleration = accelerationModifier * (dist - targetDistance)
				#if(acceleration < 0 && speed > 0):
				#	acceleration = max(acceleration * accelerationDampening, -speed)
				#if(acceleration > 0 && speed < 0):
				#	acceleration = min(acceleration * accelerationDampening, -speed)
				#speed += acceleration
				#speed = max(min(speed, maxSpeed), -maxSpeed)
			else:
				#cow shuffle before coming to a stop
				if(velocity.x != 0 || velocity.z != 0):
					velocity.x = 0
					velocity.z = 0
					shuffleTime = 0
					shuffleFrameCounter = shuffleFrames
				if(shuffleFrameCounter > 0):
					shuffleFrameCounter -= 1
					model.translation.z = -sin(shuffleTime * shuffleSpeed) * shuffleStrength * (shuffleFrameCounter as float / shuffleFrames)
		else:
			print("Cow.gd: target is null")
		
		#cows push eachother out of eachother's radius
		var cows = herd.getCows()
		var avgVec = Vector2(0, 0)
		var numInside = 0
		for i in cows:
			if(i != self):
				var cowDirVec = Vector2(
					translation.x - i.translation.x, 
					translation.z - i.translation.z)
				var dist = sqrt(pow(cowDirVec.x, 2) + pow(cowDirVec.y, 2))
				if(dist < pushDistanceThreshold):
					#UNUSED minPushDistance makes maximum push strength come at a distance of minPushDistance instead of 0
					var t = min( max( (pushDistanceThreshold + minPushDistance - dist) / pushDistanceThreshold, -1 ), 1 )
					#UNUSED makes t go from minPushPercent to 1 instead of 0 to 1
					if(minPushPercent > 0):
						t = t * ( 1.0 - minPushPercent ) + minPushPercent
					#t = pow(t, 3)
					#dist = smoothstep(0, 1, dist)
					numInside += 1
					avgVec += cowDirVec.normalized() * t
		if(numInside != 0):
			avgVec /= numInside
		pushVel = avgVec * pushStrength
	else:
		print("Cow.gd: herd is null")
	
	#gravity
	velocity.y -= 30 * delta
	if(is_on_floor()):
		velocity.y = -0.1
	elif(transform.origin.y < -20.0):
		transform.origin = Vector3(0, 10, 0)
		
	#apply velocity and move cow
	var totalVelocity = velocity + Vector3(pushVel.x, 0, pushVel.y)
	move_and_slide(totalVelocity, Vector3.UP)
	if(totalVelocity != Vector3.ZERO && lookMoveDissonance != 0):
		var moveDirection = atan2(totalVelocity.x, totalVelocity.z)
		var dissRad = lookMoveDissonance * 180.0 / PI
		rotation.y = moveDirection + min(max(moveDirection - rotation.y, -dissRad), dissRad)
