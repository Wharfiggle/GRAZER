extends Node3D

var itemDrop = preload("res://Prefabs/ItemDrop.tscn")
enum randomItemType {randomPotion, randomUpgrade, anyRandomItem, notRandom}
@export var randomItem: randomItemType
@export var potionVsUpgradeChance: float
@export var itemID: int
@export var spawnChance: float
var rng = RandomNumberGenerator.new()

func _ready():
	get_child(0).queue_free()
	rng.randomize()

func spawn(inChanceMod:float, inPrefabs:Array):
	print("spawn called on item spawner: " + str(spawnChance) + " : " + str(inChanceMod))
	var rn = rng.randf()
	if(rn <= spawnChance * inChanceMod):
		var instance = itemDrop.instantiate()
		instance.randomItem = randomItem
		instance.potionVsUpgradeChance = potionVsUpgradeChance
		instance.itemID = itemID
		instance.global_position = global_position
		get_node(NodePath("/root/Level")).add_child(instance)
	queue_free()
