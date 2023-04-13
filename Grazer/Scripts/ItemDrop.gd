extends Area3D

@onready var levelScript = get_node("/root/Level")
var item
enum randomItemType {randomPotion, randomUpgrade, anyRandomItem, notRandom}
@export var randomItem: randomItemType
@export var potionVsUpgradeChance: float
@export var itemID: int
@onready var meshMat = get_child(0).get_surface_override_material(0)
@onready var origPos = position
var time = 0.0
@export var bobSpeed = 3.0
@export var bobStrength = 0.15
@export var spinSpeed = 2.0
var waited = false

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass
	
func _physics_process(delta):
	if(!waited):
		if(randomItem == randomItemType.randomPotion):
			item = levelScript.getRandomPotion()
		elif(randomItem == randomItemType.randomUpgrade):
			item = levelScript.getRandomUpgrade()
		elif(randomItem == randomItemType.notRandom):
			item = levelScript.getItem(itemID)
		else:
			item = levelScript.getRandomItem(potionVsUpgradeChance)
		meshMat.albedo_texture = item.icon
		waited = true
		
	time += delta
	position.y = sin(time * bobSpeed) * bobStrength
	rotation.y += spinSpeed * delta

func _on_body_entered(body):
	if(body.is_in_group('Player')):
		if(item.wepLevel == -1):
			#add item to player inventory if potion
			print("add potion")
		else:
			item.use(true)
		queue_free()
