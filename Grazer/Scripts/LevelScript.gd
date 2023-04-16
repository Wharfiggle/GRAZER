extends Node3D

#audioStream
@onready var music = $BackgroundPlayer

#music
var sound = preload("res://sounds/Copy of Opening Theme Demo 1.WAV")
@onready var inventory = $ItemWheel
@onready var player = get_node(NodePath("./Player"))
@export var broadcastStartExitTime = 0.2
var broadcastTimer = 0.0
var broadcastTime = 0.0
@onready var broadcast = get_node(NodePath("./Broadcast"))
@export var broadcastHeight = 200
@onready var broadcastOrigPos = broadcast.position
#levels 1, 2, 3 for capacity, damage, reload for revolver, shotgun
var gunStats = [ [7, 8, 9], [3.5, 4.0, 4.5], [0.8, 0.6, 0.4], [3, 4, 5], [0.75, 1.0, 1.25], [0.6, 0.4, 0.2] ]
var itemTextures = [
	preload("res://Assets/Images/shotgunUpgradeIcon.png"),
	preload("res://Assets/Images/revolvUpgradeIcon.png"),
	null,
	null,
	null,
	null,
	preload("res://Assets/Images/remedyElixir.png"),
	preload("res://Assets/Images/bulletstormElixir.png"),
	preload("res://Assets/Images/lifeleachElixir.png"),
	preload("res://Assets/Images/dustkickerElixir.png"),
	preload("res://Assets/Images/liquidluckElixir.png"),
	preload("res://Assets/Images/dauntlessElixir.png")
]

class Item:
	var id
	var name = "dork"
	var description = ":^O)"
	var icon
	var cost = 0
	var player
	var levelScript
	var wepLevel = -1 # only for weapon upgrades
	#levels 1, 2, 3 for capacity, damage, reload for revolver, shotgun
	var gunStats = [ [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0] ]
	func _init(inId:int, inPlayer:Node, inTexture):
		id = inId
		player = inPlayer
		icon = inTexture
		if(id == 0): name = "Revolver Capacity Upgrade"
		elif(id == 1): name = "Revolver Damage Upgrade"
		elif(id == 2): name = "Revolver Reload Speed Upgrade"
		elif(id == 3): name = "Shotgun Capacity Upgrade"
		elif(id == 4): name = "Shotgun Damage Upgrade"
		elif(id == 5): name = "Shotgun Reload Speed Upgrade"
		elif(id == 6): name = "Health"
		elif(id == 7): name = "Bulletstorm"
		elif(id == 8): name = "Life Leach"
		elif(id == 9): name = "Dustkicker"
		elif(id == 10): name = "Liquid Luck"
		elif(id == 11): name = "Dauntless"
	func initUpgrade(inLevelScript:Node, inLevel:int, inGunStats:Array):
		levelScript = inLevelScript
		wepLevel = inLevel
		gunStats = inGunStats
		if(wepLevel == 1):
			cost = 10
		elif(wepLevel == 2):
			cost = 15
		elif(wepLevel == 3):
			cost = 20
		if(id == 0 || id == 1 || id == 2): #revolverCapacity, revolverDamage, revolverReload
			if(id == 0):
				description = "Upgraded Revolver Capacity to Level: " + str(wepLevel)
			elif(id == 1):
				description = "Upgraded Revolver Damage to Level: " + str(wepLevel)
			elif(id == 2):
				description = "Upgraded Revolver Reload to Level: " + str(wepLevel)
		elif(id == 3 || id == 4 || id == 5): #shotgunCapacity, shotgunDamage, shotgunReload
			if(id == 3):
				description = "Upgraded Shotgun Capacity to Level: " + str(wepLevel)
			elif(id == 4):
				description = "Upgraded Shotgun Damage to Level: " + str(wepLevel)
			elif(id == 5):
				description = "Upgraded Shotgun Reload to Level: " + str(wepLevel)
	func use(useOrUndo:bool):
		var undoMod = 1
		if(!useOrUndo): undoMod = -1
		if(id >= 0 && id <= 5):
			player.gunStats[id] = gunStats[id][wepLevel - 1]
			player.updateGunStats()
			levelScript.broadcastMessage(description, 3.0)
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
		elif(id == 11): #dauntless
			print("sixth potion")

#use for getting specific upgrade
func getUpgrade(id:int) -> Item:
	var level = 1
	var ind = 0
	while(level == 1 && ind < 3):
		if(player.gunStats[id] == gunStats[id / 3][ind]):
			level = ind + 2
		ind += 1
	var item
	if(level == 4):
		#if gun stat is max, return health potion instead
		item = Item.new(6, player, itemTextures[6])
	else:
		item = Item.new(id, player, itemTextures[id / 3 as int]) # get tex 0 if id is 0 - 2 and get tex 1 if id is 3 - 5
		item.initUpgrade(self, level, gunStats)
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
	
#use for getting any item
func getItem(id:int) -> Item:
	id = min(max(id, 0), 11)
	if(id < 6):
		return getUpgrade(id)
	else:
		return getPotion(id)
#use for getting any random item
func getRandomItem(potionVsUpgradeChance:float = 0.5) -> Item:
	var rn = randf()
	if(rn <= potionVsUpgradeChance):
		return getRandomPotion()
	else:
		return getRandomUpgrade()

func broadcastMessage(message:String, time:float):
	broadcastTime = time + 2 * broadcastStartExitTime
	broadcastTimer = broadcastTime
	broadcast.get_child(2).text = message

# Called when the node enters the scene tree for the first time.
func _ready():
	#selecting sound to play
	music.stream = sound
	#Starting sound
	music.play(5.37)
	inventory.visible = false 
	
	broadcast.position.y -= broadcastHeight

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(player == null):
		player = get_node(NodePath("/root/Level/Player"))
	
	if(Input.is_action_just_pressed("debug1")):
		broadcastMessage("mumu", 1.0)
	
	#make broadcast message move smoothly on and off screen
	if(broadcastTimer > 0):
		broadcastTimer -= delta
		if(broadcastTimer < 0):
			broadcastTimer = 0
		var startT = 1.0 - min(1.0, (broadcastTime - broadcastTimer) / broadcastStartExitTime)
		var endT = 1.0 - min(1.0, broadcastTimer / broadcastStartExitTime)
		var t = startT
		if(endT != 0):
			t = endT
		t = pow(t, 2)
		broadcast.position.y = broadcastOrigPos.y - broadcastHeight * t
