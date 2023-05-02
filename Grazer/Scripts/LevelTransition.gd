extends Node3D

@onready var usable = get_child(0)
@onready var player = get_node(NodePath("/root/Level/Player"))
@onready var terrain = get_node(NodePath("/root/Level/AllTerrain"))
@onready var level = get_node(NodePath("/root/Level"))
@export var exit = false

func _process(_delta):
	if(player == null):
		player = get_node(NodePath("/root/Level/Player"))
	if(terrain == null):
		terrain = get_node(NodePath("/root/Level/AllTerrain"))
	if(level == null):
		level = get_node(NodePath("/root/Level"))

func use():
	if(!exit):
		terrain.spawnChanceMod += 0.5
	usable.active = false
	player.active = false
	if(!exit):
		level.changeMusic(2)
	else:
		level.changeMusic(0)
	await Fade.fade_out(1).finished
	player.position.z -= 7
	if(!exit):
		player.hitpoints = player.maxHitpoints
	var cows = player.herd.getCows()
	var cowPos = player.position
	cowPos.z += 2
	for i in cows.size():
		cows[i].position = cowPos + Vector3(randf() * 2 - 1, 0, randf() * 2 - 1)
	await Fade.fade_in(1).finished
	player.active = true
