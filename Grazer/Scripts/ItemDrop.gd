#Elijah Southman
extends Area3D

var levelScript
var item
enum randomItemType {randomElixir, randomUpgrade, anyRandomItem, notRandom}
@export var randomItem: randomItemType
@export var elixirVsUpgradeChance: float
@export var itemID: int
@onready var meshMat1 = get_child(0).get_material_overlay()
@onready var meshMat2 = get_child(0).get_material_override()
@onready var meshMat3 = get_child(1).get_material_override()
@onready var origPos = position
var time = 0.0
@export var bobSpeed = 3.0
@export var bobStrength = 0.15
@export var spinSpeed = 2.0
var waited = false
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group('DespawnAtCheckpoint')

func _physics_process(delta):
	if(!waited):
		levelScript = get_node("/root/Level")
		player = levelScript.find_child("Player")
		if(randomItem == randomItemType.randomElixir):
			item = levelScript.getRandomPotion()
		elif(randomItem == randomItemType.randomUpgrade):
			item = levelScript.getRandomUpgrade()
		elif(randomItem == randomItemType.notRandom):
			item = levelScript.getItem(itemID)
		else:
			item = levelScript.getRandomItem(elixirVsUpgradeChance)
		meshMat1.albedo_texture = item.icon
		meshMat2.albedo_texture = item.icon
		meshMat3.albedo_texture = item.icon
		get_child(0).visible = true
		get_child(1).visible = true
		waited = true
	
	time += delta
	position.y = sin(time * bobSpeed) * bobStrength
	rotation.y += spinSpeed * delta

func _on_body_entered(body):
	if(waited):
		if(body.is_in_group('Player')):
			if(item.wepLevel == -1):
				player.inventory[item.id - 6] += 1
				levelScript.broadcastMessage("Obtained " + item.name + " Elixir", 3.0)
			else:
				item.use(true)
			queue_free()
			SceneCounter.items -= 1
