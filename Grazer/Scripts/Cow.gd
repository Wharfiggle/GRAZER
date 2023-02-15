extends KinematicBody

export (NodePath) var targetNodePath = "../Ball"
export (float) var speed = 8
export (float) var lookSpeed = 3
export (float) var followDistance = 5
var target
var velocity = Vector3(0, 0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	target = get_node(targetNodePath)
	if(target == null):
		print(targetNodePath)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(target != null):
		var targetVector = Vector2(
			translation.x - target.global_translation.x,
			translation.z - target.global_translation.z)
		if(Input.is_action_pressed("cowParty")):
			rotate_y(speed)
		else:
			rotation.y = lerp_angle(rotation.y, atan2(
				targetVector.x,
				targetVector.y), lookSpeed * delta)
		if(sqrt(pow(targetVector.x, 2) + pow(targetVector.y, 2)) > followDistance):
			velocity.x = -sin(rotation.y) * speed
			velocity.z = -cos(rotation.y) * speed
		else:
			velocity.x = 0
			velocity.z = 0
	velocity.y -= 30 * delta
	if(is_on_floor()):
		velocity.y = -0.1
	move_and_slide(velocity, Vector3.UP)
