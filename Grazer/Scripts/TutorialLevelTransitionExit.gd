extends Node3D

@onready var player = get_node(NodePath("/root/Level/Player"))
@onready var level = get_node(NodePath("/root/Level"))

func _process(_delta):
	if(player == null):
		player = get_node(NodePath("/root/Level/Player"))
	if(level == null):
		level = get_node(NodePath("/root/Level"))

func use():
	level.changeMusic(0)
	player.active = false
	await Fade.fade_out(1).finished
	var cows = player.herd.getCows()
	WorldSave.cows = []
	for i in cows.size():
		WorldSave.cows.append(cows[i].cowTypeInd)
	WorldSave.elixirs = player.inventory
	WorldSave.upgrades = player.gunStats
	get_tree().change_scene_to_file("res://Levels/Level.tscn")
