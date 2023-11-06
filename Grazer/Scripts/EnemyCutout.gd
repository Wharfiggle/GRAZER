#Elijah Southman
extends RigidBody3D

var parent
@export var knockbackStrength = 500
var used = false

func _ready():
	freeze = true
	parent = get_parent()

func damage_taken(damage:float, from:String, critHit:bool = false, bullet:Node = null) -> bool:
	if(from != "enemy" && !used):
		apply_force(bullet.velocity.normalized() * knockbackStrength)
		use()
		return true
	else:
		return false

func use():
	used = true
	freeze = false
	if(parent.has_method("use")):
		parent.use()
