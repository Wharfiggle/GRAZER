#Elijah Southman

extends Node3D

var active = true
var parent
@onready var lever = $Lever/Lever
@onready var origLeverRotation = lever.rotation.x
@onready var targetRotation = origLeverRotation
@onready var usable = $Usable

# Called when the node enters the scene tree for the first time.
func _ready():
	parent = get_parent()
	
func _process(delta):
	if(lever != null):
		lever.rotation.x = lerpf(lever.rotation.x, targetRotation, 9 * delta)
	else:
		lever = $Lever/Lever
		origLeverRotation = lever.rotation.x
		targetRotation = origLeverRotation

func use():
	if(active):
		parent.use()
		targetRotation = -targetRotation

func deactivate():
	active = false
	usable.deactivate()
