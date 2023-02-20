extends KinematicBody

export (NodePath) var targetNodePath = NodePath("/root/Level/Ball")
export (float) var targetSpeed = 8.0
export (float) var accelerationModifier = 0.1
export (float) var accelerationDampening = 30.0
export (float) var accDampRandOffset = 10.0
export (float) var lookSpeed = 3.0
export (float) var followDistance = 5.0
var target
var velocity = Vector3(0, 0, 0)
var speed = 0.0
var acceleration = 0.0
var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	accelerationDampening = rng.randf_range(accelerationDampening - accDampRandOffset, accelerationDampening + accDampRandOffset)
	#accelerationModifier = rng.randf_range(accelerationModifier - 0.05, accelerationDampening + 0.05)
	target = get_node(targetNodePath)
	if(target == null):
		print("Cow.gd: " + targetNodePath + " is an invalid NodePath")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(target != null):
		var targetVector = Vector2(
			translation.x - target.global_translation.x,
			translation.z - target.global_translation.z)
		
		if(Input.is_action_pressed("cowParty")):
			rotate_y(targetSpeed)
		else:
			rotation.y = lerp_angle(
				rotation.y, 
				atan2(targetVector.x, targetVector.y), 
				lookSpeed * delta)
		
		var dist = sqrt(pow(targetVector.x, 2) + pow(targetVector.y, 2))
		var prevAcc = acceleration
		acceleration = accelerationModifier * (dist - followDistance)
		if(acceleration < 0 && speed > 0):
			acceleration = max(acceleration * accelerationDampening, -speed)
		if(acceleration > 0 && speed < 0):
			acceleration = min(acceleration * accelerationDampening, -speed)
		speed += acceleration
		speed = max(min(speed, targetSpeed), -targetSpeed)
		velocity.x = -sin(rotation.y) * speed
		velocity.z = -cos(rotation.y) * speed
	
	velocity.y -= 30 * delta
	if(is_on_floor()):
		velocity.y = -0.1
	elif(transform.origin.y < -20.0):
		transform.origin = Vector3(0, 10, 0)
	move_and_slide(velocity, Vector3.UP)
