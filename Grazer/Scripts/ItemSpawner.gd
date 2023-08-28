#Elijah Southman
extends Node3D

var itemDrop = preload("res://Prefabs/ItemDrop.tscn")
enum randomItemType {randomElixir, randomUpgrade, anyRandomItem, notRandom}
@export var randomItem: randomItemType
@export var elixirVsUpgradeChance: float
@export var itemID: int
@export var spawnChance: float
var rng = RandomNumberGenerator.new()
var waitedToBeIndependent = false
@onready var terrain = get_node("/root/Level/AllTerrain")

func _ready():
	get_child(0).queue_free()
	rng.randomize()
	
func _physics_process(delta):
	if(waitedToBeIndependent):
		if(terrain == null):
			terrain = get_node("/root/Level/AllTerrain")
		elif(!terrain.real):
			spawn(terrain.spawnChanceMod, terrain.enemyPrefabs)
	elif(!waitedToBeIndependent):
		waitedToBeIndependent = true

func spawn(inChanceMod:float, _inPrefabs:Array):
	#print("spawn called on item spawner: " + str(spawnChance) + " : " + str(inChanceMod))
	var rn = rng.randf()
	if(rn <= spawnChance * inChanceMod):
		var instance = itemDrop.instantiate()
		SceneCounter.items += 1
		instance.randomItem = randomItem
		instance.elixirVsUpgradeChance = elixirVsUpgradeChance
		instance.itemID = itemID
		get_node(NodePath("/root/Level")).add_child(instance)
		instance.global_position = global_position
	queue_free()
