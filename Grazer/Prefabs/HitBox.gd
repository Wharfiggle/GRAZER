#Elijah Southman
extends StaticBody3D

@onready var parent = get_parent()

func damage_taken(damage:float, from:String, critHit:bool = false, bullet:Node = null) -> bool:
	return parent.damage_taken(damage, from, critHit, bullet)
