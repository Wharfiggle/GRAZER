extends KinematicBody

export (NodePath) var targetNodePath
export (float) var speed
export (float) var lookSpeed
var target
var velocity = Vector3(0, 0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	target = get_node(targetNodePath)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_action_pressed("cowParty")):
		rotate_y(speed)
	else:
		rotation.y = lerp_angle(rotation.y, atan2(
			translation.x - target.global_translation.x, 
			translation.z - target.global_translation.z), lookSpeed * delta)
	velocity.x = cos(rotation.y) * speed * delta
	velocity.z = sin(rotation.y) * speed * delta
	velocity.y -= 30 * delta
	if(is_on_floor()):
		velocity.y = -0.1
	move_and_slide(velocity, Vector3.UP)
