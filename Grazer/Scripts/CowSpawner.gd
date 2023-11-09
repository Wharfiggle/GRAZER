extends Node3D

@export var spawnChance:float
enum cowTypes {common, red, lucky, grandRed, ironhide, moxie, checkpointMarker}
@export var cowType:cowTypes
var rng = RandomNumberGenerator.new()
var herd
var waitedToBeIndependent = false
@onready var terrain = get_node("/root/Level/AllTerrain")
@export var strayMoo = true

# Called when the node enters the scene tree for the first time.
func _ready():
	get_child(0).queue_free()
	rng.randomize()
	herd = get_node(NodePath("/root/Level/Herd"))
	global_position.y = 0

func _physics_process(delta):
	if(waitedToBeIndependent):
		if(terrain == null):
			terrain = get_node("/root/Level/AllTerrain")
		elif(herd == null):
			herd = get_node(NodePath("/root/Level/Herd"))
		elif(!terrain.real):
			spawn(terrain.spawnChanceMod, terrain.enemyPrefabs)
	elif(!waitedToBeIndependent):
		waitedToBeIndependent = true

func spawn(inChanceMod:float, _inPrefabs:Array):
	if(herd == null):
		herd = get_node(NodePath("/root/Level/Herd"))
	spawnChance *= inChanceMod
	var rn = rng.randf()
	for i in spawnChance + 1 as int:
		if(spawnChance >= i + 1 || rn < fmod(spawnChance, 1.0)):
			var offset = Vector3(rng.randf() - 0.5, 0, rng.randf() - 0.5)
			var cow
			if(cowType != cowTypes.checkpointMarker):
				cow = herd.spawnStrayCow(global_position + offset, cowType)
			else:
				cow = herd.spawnCheckpointMarker(global_position + offset)
			cow.rotation.y = rotation.y
			if(!strayMoo):
				cow.mooIndicatorTime = -1
				cow.mooIndicatorTimer = -1
			print("spawned cow at " + str(global_position + offset))
	queue_free()
