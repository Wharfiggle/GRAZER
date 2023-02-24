extends KinematicBody

export (float) var maxSpeed = 9.0
export (float) var accelerationModifier = 0.1
export (float) var accelerationDampening = 40.0
export (float) var accDampRandOffset = 20.0
export (float) var lookSpeed = 3.0
export (float) var followDistance = 3.0
export (float) var pushStrength = 30.0
export (float) var pushDistanceThreshold = 1.5
export (float) var minPushDistance = 0.0
export (float) var minPushPercent = 0.0
var herd
var velocity = Vector3(0, 0, 0)
var speed = 0.0
var acceleration = 0.0
var rng = RandomNumberGenerator.new()
var follow = true
var pushVel = Vector2(0, 0)
var huddling = false
var target

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	accelerationDampening = rng.randf_range(accelerationDampening - accDampRandOffset, accelerationDampening + accDampRandOffset)
	#accelerationModifier = rng.randf_range(accelerationModifier - 0.05, accelerationDampening + 0.05)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(herd != null):
		if(target != null):
			var targetVector = Vector2(
				translation.x - target.x,
				translation.z - target.y)
			
			if(Input.is_action_pressed("cowParty")):
				rotate_y(maxSpeed)
			else:
				rotation.y = lerp_angle(
					rotation.y, 
					atan2(targetVector.x, targetVector.y), 
					lookSpeed * delta)
			
			var dist = sqrt(pow(targetVector.x, 2) + pow(targetVector.y, 2))
			if(herd.canHuddle && dist < followDistance && huddling == false):
				huddling = true
				herd.addHuddler(self)
			#elif(dist > followDistance * 2 && huddling == true):
				#huddling = false
				#herd.removeHuddler(self)
			if(huddling == false && follow):
				#var prevAcc = acceleration
				#acceleration = accelerationModifier * (dist - followDistance)
				#if(acceleration < 0 && speed > 0):
				#	acceleration = max(acceleration * accelerationDampening, -speed)
				#if(acceleration > 0 && speed < 0):
				#	acceleration = min(acceleration * accelerationDampening, -speed)
				#speed += acceleration
				#speed = max(min(speed, maxSpeed), -maxSpeed)
				
				#speed = maxSpeed
				#if(dist < followDistance - maxSpeed * 0.3):
				#	speed = -maxSpeed
				#elif(dist < followDistance && dist >= followDistance - maxSpeed * 0.5):
				#	speed = 0
				
				speed = max(min(dist - followDistance, 1), -1) * maxSpeed
				velocity.x = -sin(rotation.y) * speed
				velocity.z = -cos(rotation.y) * speed
			else:
				velocity.x = 0
				velocity.z = 0
		else:
			print("Cow.gd: target is null")
		
		var cows = herd.getCows()
		var avgVec = Vector2(0, 0)
		var numInside = 0
		for i in cows:
			if(i != self):
				var cowDirVec = Vector2(translation.x - i.translation.x, translation.z - i.translation.z)
				var dist = sqrt(pow(cowDirVec.x, 2) + pow(cowDirVec.y, 2))
				if(dist < pushDistanceThreshold):
					var t = min(max((pushDistanceThreshold + minPushDistance - dist) / pushDistanceThreshold, -1), 1)
					#makes t go from minPushPercent to 1 instead of 0 to 1
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
	
	velocity.y -= 30 * delta
	if(is_on_floor()):
		velocity.y = -0.1
	elif(transform.origin.y < -20.0):
		transform.origin = Vector3(0, 10, 0)
	move_and_slide(velocity + Vector3(pushVel.x, 0, pushVel.y), Vector3.UP)
