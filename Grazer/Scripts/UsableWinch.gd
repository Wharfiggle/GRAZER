extends Node3D

var active = true
var parent
@onready var wheel = $"Chain Wheel/RotationPoint"
@export var origWheelRotation = 1800 * PI / 180
@onready var targetRotation = origWheelRotation
@onready var usable = $Usable
var atRotation = true

# Called when the node enters the scene tree for the first time.
func _ready():
	parent = get_parent()
	
func _process(delta):
	if(wheel != null):
		wheel.rotation.x = lerpf(wheel.rotation.x, targetRotation, 0.3)
		if(abs(wheel.rotation.x - targetRotation) < 0.1):
			wheel.rotation.x = targetRotation
			atRotation = true
	else:
		wheel = $"Chain Wheel/RotationPoint"
		targetRotation = origWheelRotation

func use():
	if(active && atRotation):
		parent.use()
		targetRotation = -targetRotation
		atRotation = false
	else:
		print("asdasd")

func deactivate():
	active = false
	usable.deactivate()
