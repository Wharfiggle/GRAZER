#Elijah Southman

extends Node3D

@onready var herdMenu = get_node(NodePath("/root/Level/HerdMenu"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if(herdMenu == null):
		herdMenu = get_node(NodePath("/root/Level/HerdMenu"))
		
func use():
	herdMenu.use()
