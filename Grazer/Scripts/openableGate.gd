extends Node3D

@export var closable = false
@onready var right = $GateRight
@onready var left = $GateLeft
@export var openDegrees = 100
@onready var rightStart = right.rotation.y
@onready var leftStart = left.rotation.y
@onready var rightTarget = rightStart - openDegrees * PI / 180.0
@onready var leftTarget = leftStart + openDegrees * PI / 180.0
@export var openTime = 2.0
var openTimer = 0
var opened = false

func use():
	if(openTimer <= 0 && (closable || !opened)):
		opened = !opened
		openTimer = openTime
		if(!closable):
			var usable = get_node(NodePath("./Usable"))
			if(usable != null):
				usable.active = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(openTimer > 0):
		openTimer -= delta
		var t = max(0, openTimer / openTime)
		if(opened):
			t = smoothstep(0, 1, 1.0 - t)
		else:
			t = smoothstep(0, 1, t)
		right.rotation.y = lerpf(rightStart, rightTarget, t)
		left.rotation.y = lerpf(leftStart, leftTarget, t)
