#Elijah Southman
extends StaticBody3D

@onready var parent = get_parent()

func damage_taken(damage:float, from:String, critHit:bool = false, bullet:Node = null) -> bool:
 	return parent.damage_taken(damage, from, critHit, bullet)

func knockback(damageSourcePos:Vector3, kSpeed:float, useModifier:bool) -> bool:
	#print("hitbox knockback: " + str(damageSourcePos))
	return parent.knockback(damageSourcePos, kSpeed, useModifier)
