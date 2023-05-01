#Elijah Southman

extends Node3D

@onready var elixirGunMenu = get_node(NodePath("/root/Level/ElixirGunMenu"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if(elixirGunMenu == null):
		elixirGunMenu = get_node(NodePath("/root/Level/ElixirGunMenu"))
		
func use():
	elixirGunMenu.use()
