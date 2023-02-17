extends KinematicBody

export (NodePath) var targetNodePath = "../Ball/EnemyCircle"
export (float) var circleSpeed = 3
export (float) var lookSpeed = 1
export (float) var followDistance = 10
export (float) var radius = 30
export (float) var d = 0 #counter for _process
var target
var velocity = Vector3(0, 0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	target = get_node(targetNodePath)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	d += delta
	
	var targetVector = Vector2(
		translation.x - target.global_translation.x,
		translation.z - target.global_translation.z)
	
	velocity.x = sin(d * circleSpeed) * radius
	velocity.z = cos(d * circleSpeed) * radius
	
	
	velocity.y -= 30 * delta
	if(is_on_floor()):
		velocity.y = -0.1
	move_and_slide(velocity, Vector3.UP)
