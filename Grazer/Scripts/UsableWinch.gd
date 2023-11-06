extends Node3D

var active = true
var parent
@onready var wheel = $"Chain Wheel/RotationPoint"
@export var origWheelRotation = 1800 * PI / 180
@onready var targetRotation = origWheelRotation
@onready var usable = $Usable

# Called when the node enters the scene tree for the first time.
func _ready():
	parent = get_parent()
	
func _process(delta):
	if(wheel != null):
		wheel.rotation.x = lerpf(wheel.rotation.x, targetRotation, 0.3)
		if(abs(wheel.rotation.x - targetRotation) < 0.01):
			wheel.rotation.x = targetRotation
	else:
		wheel = $"Chain Wheel/RotationPoint"
		targetRotation = origWheelRotation

func use():
	if(active && wheel.rotation.x == targetRotation):
		parent.use()
		targetRotation = -targetRotation

func deactivate():
	active = false
	usable.deactivate()
