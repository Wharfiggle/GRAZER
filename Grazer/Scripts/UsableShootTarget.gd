#Elijah Southman

extends StaticBody3D

var waited = false
var parent = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(waited):
		parent = get_parent()
	else:
		waited = true

func damage_taken(damage:float, from:String, inCritHit:bool = false, inBullet:Node = null) -> bool:
	if(parent.shootable && parent.active && from == "player"):
		print("bullet hit the thing")
		parent.use()
	return true
