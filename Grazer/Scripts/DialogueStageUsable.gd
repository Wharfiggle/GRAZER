#Elijah Southman

extends Node3D

func use():
	var parent = get_parent()
	parent.setStage(parent.stage + 1)
