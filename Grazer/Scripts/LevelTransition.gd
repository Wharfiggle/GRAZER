extends Node3D

@onready var usable = get_child(0)
@onready var player = get_node(NodePath("/root/Level/Player"))
@onready var terrain = get_node(NodePath("/root/Level/AllTerrain"))
@onready var level = get_node(NodePath("/root/Level"))
@export var exit = false
var passed = false

func _process(_delta):
	if(player == null):
		usable.active = false
		player = get_node(NodePath("/root/Level/Player"))
	else:
		if(player.herd.cowsBeingStolen > 0):
			usable.active = false
		else:
			usable.active = !passed
	if(terrain == null):
		terrain = get_node(NodePath("/root/Level/AllTerrain"))
	if(level == null):
		level = get_node(NodePath("/root/Level"))

func use():
	if(!exit):
		terrain.spawnChanceMod += 0.65
		level.changeMusic(2)
	else:
		level.changeMusic(0)
	usable.active = false
	passed = true
	player.active = false
	await Fade.fade_out(1).finished
	player.position.z -= 7
	if(!exit):
		var delete = get_tree().get_nodes_in_group("DespawnAtCheckpoint")
		var toDelete = []
		var toQueueFree = []
		for i in delete:
			if(!i.has_method("delete")):
				i.queue_free()
			else:
				if(i.is_in_group("Enemy") && i.draggedCow != null):
					i.herd.removeCow(i.draggedCow)
					i.draggedCow.delete()
				i.delete()
		player.updateHealth(player.maxHitpoints)
	var cows = player.herd.getCows()
	var cowPos = player.position
	cowPos.z += 2
	for i in cows.size():
		cows[i].position = cowPos + Vector3(randf() * 2 - 1, 0, randf() * 2 - 1)
	await Fade.fade_in(1).finished
	player.active = true
