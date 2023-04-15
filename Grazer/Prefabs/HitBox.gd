extends StaticBody3D

@onready var parent = get_parent()

func damage_taken(damage:float, from:String, bullet:Node) -> bool:
	return parent.damage_taken(damage, from, bullet)
