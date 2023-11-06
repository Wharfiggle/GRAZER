extends Node3D

@export var numberOfUses = 3
var currentUses = 0
var parent

func _ready():
	parent = get_parent()

func use():
	currentUses += 1
	if(currentUses == numberOfUses):
		parent.use()
