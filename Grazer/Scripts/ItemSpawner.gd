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

func spawn(inChanceMod:float, _inPrefabs:Array):
	var rn = rng.randf()
	if(rn <= spawnChance * inChanceMod):
		var instance = itemDrop.instantiate()
		instance.randomItem = randomItem
		instance.potionVsUpgradeChance = potionVsUpgradeChance
		instance.itemID = itemID
	queue_free()
