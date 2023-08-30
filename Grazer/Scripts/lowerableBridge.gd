extends Node3D

@export var raisable = false
@onready var rotate = $RotatingPoint
@export var startAngle = -100
@export var endAngle = 0
@export var lowerTime = 2.0
var lowerTimer = 0
var lowered = false

func _ready():
	startAngle *= PI / 180.0
	endAngle *= PI / 180.0
	rotate.rotation.x = startAngle

func use():
	if(lowerTimer <= 0 && (raisable || !lowered)):
		lowered = !lowered
		lowerTimer = lowerTime
		if(!raisable):
			var usable = get_node(NodePath("./Usable"))
			if(usable != null):
				usable.active = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(lowerTimer > 0):
		lowerTimer -= delta
		var t = max(0, lowerTimer / lowerTime)
		if(lowered):
			t = smoothstep(0, 1, 1.0 - t)
		else:
			t = smoothstep(0, 1, t)
		rotate.rotation.x = lerpf(startAngle, endAngle, t)
