extends Node3D

#audioStream
@onready var music = $BackgroundPlayer

#music
var sound = preload("res://sounds/Copy of Opening Theme Demo 1.WAV")
@onready var inventory = $ItemWheel
@onready var player = get_node(NodePath("/root/Level/Player"))
#levels 1, 2, 3 for capacity, damage, reload for revolver, shotgun
var gunStats = [ [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0] ]
var itemTextures = [
	preload("res://Assets/Images/empress of bostonia.png"),
	preload("res://Assets/Images/handsomestaringeagle.jpg"),
	null,
	null,
	null,
	null,
	preload("res://Assets/Images/the creature.jpg"),
	preload("res://Assets/Images/the creature.jpg"),
	preload("res://Assets/Images/the creature.jpg"),
	preload("res://Assets/Images/the creature.jpg"),
	preload("res://Assets/Images/the creature.jpg"),
	preload("res://Assets/Images/the creature.jpg")
]

class Item:
	var id
	var description = ":^O)"
	var icon
	var cost = 0
	var player
	var level = 1 # only for weapon upgrades
	#levels 1, 2, 3 for capacity, damage, reload for revolver, shotgun
	var gunStats = [ [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0] ]
	func _init(inId:int, inPlayer:Node, inTexture):
		id = inId
		player = inPlayer
		icon = inTexture
	func initUpgrade(inLevel:int, inGunStats:Array):
		level = inLevel
		gunStats = inGunStats
		if(level == 1):
			cost = 10
		elif(level == 2):
			cost = 15
		elif(level == 3):
			cost = 20
		if(id == 0 || id == 1 || id == 2): #revolverCapacity, revolverDamage, revolverReload
			if(id == 0):
				description = "Upgraded Revolver Capacity to Level: " + str(level)
			elif(id == 1):
				description = "Upgraded Revolver Damage to Level: " + str(level)
			elif(id == 2):
				description = "Upgraded Revolver Reload to Level: " + str(level)
		elif(id == 3 || id == 4 || id == 5): #shotgunCapacity, shotgunDamage, shotgunReload
			if(id == 0):
				description = "Upgraded Shotgun Capacity to Level: " + str(level)
			elif(id == 1):
				description = "Upgraded Shotgun Damage to Level: " + str(level)
			elif(id == 2):
				description = "Upgraded Shotgun Reload to Level: " + str(level)
	func use(useOrUndo:bool):
		var undoMod = 1
		if(!useOrUndo): undoMod = -1
		if(id >= 0 && id <= 5):
			player.gunStats[id] = gunStats[id][level - 1]
			#todo: also broadcast description
		elif(id == 6): #health
			player.hitpoints += 0.5 * player.hitpoints
			if(player.hitpoints > player.maxHitpoints):
				player.hitpoints = player.maxHitpoints
		elif(id == 7): #bulletstorm
			player.infiniteAmmo = useOrUndo
		elif(id == 8): #life leach
			player.lifeLeach += 0.1 * undoMod
		elif(id == 9): #dustkicker
			player.potionSpeedup += 1.0 * undoMod
		elif(id == 10): #liquid luck
			player.alwaysCrit = useOrUndo

#use for getting specific upgrade
func getUpgrade(id:int) -> Item:
	var level = -1
	var ind = 0
	while(level == -1):
		if(player.gunStats[id] == gunStats[id][ind]):
			level = ind
		ind += 1
	var item = Item.new(id, player, itemTextures[id / 3])
	item.initUpgrade(level, gunStats)
	return item
	
#use for getting random upgrade to drop in world
func getRandomUpgrade() -> Item:
	var rn = 0
	var valid = false
	var tried = []
	while(valid == false && tried.size() < 6):
		rn = randi_range(0, 5)
		if(!tried.has(rn)):
			tried.append(rn)
			#if player's respective gun stat isn't equal to the max level, then it's valid
			if(player.gunStats[rn] != gunStats[rn][2]):
				valid = true
	#if all gun stats are max, return health potion instead
	if(valid == false):
		return Item.new(6, player, itemTextures[6])
	else:
		return getUpgrade(rn)

#use for getting specific potion
func getPotion(id:int) -> Item:
	id = min(max(id, 6), 11)
	return Item.new(id, player, itemTextures[id])

#use for getting random potion to drop in world
func getRandomPotion() -> Item:
	var rn = randi_range(6, 11)
	return getPotion(rn)


# Called when the node enters the scene tree for the first time.
func _ready():
	#selecting sound to play
	music.stream = sound
	#Starting sound
	music.play(5.37)
	inventory.visible = false 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(player == null):
		player = get_node(NodePath("/root/Level/Player"))
