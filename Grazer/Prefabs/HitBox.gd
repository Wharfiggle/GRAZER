extends StaticBody3D

@onready var parent = get_parent()

func damage_taken(damage, from) -> bool:
	return parent.damage_taken(damage, from)
