#Elijah Southman
extends Node3D
#@export var objectStringToSpawn = ""
var gunman
var thief
var rng = RandomNumberGenerator.new()
#how likely a gunman will spawn vs a thief. 0 is 0%, 1 is 100%
@export var gunmanSpawnChance:float
#how likely it is an enemy will spawn. 0 is 0%, 1 is 100%.
@export var spawnChance:float
@export var numEnemies:int
@export var timeDelay:float
@export var spawnAtEdgeOfScreen:bool
@export var sentryMode:bool
@export var canDropItems:bool = true
var levelScript
var timer = -1.0
var chanceMod = 0
var prefabs = []
@onready var terrain = get_node("/root/Level/AllTerrain")
var waitedToBeIndependent = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_child(0).queue_free()
	rng.randomize()

func _physics_process(delta):
	if(waitedToBeIndependent && prefabs.is_empty()):
		if(terrain == null):
			terrain = get_node("/root/Level/AllTerrain")
		elif(!terrain.real):
			spawn(terrain.spawnChanceMod, terrain.enemyPrefabs)
	elif(!waitedToBeIndependent):
		waitedToBeIndependent = true
	
	if(timer > -1):
		timer -= delta
		if(timer <= 0):
			spawnEnemy()
			numEnemies -= 1
			if(numEnemies <= 0):
				queue_free()
			else:
				timer = timeDelay

func spawn(inChanceMod:float, inPrefabs:Array):
	chanceMod = inChanceMod
	prefabs = inPrefabs
	timer = timeDelay
	if(spawnAtEdgeOfScreen):
		levelScript = get_node(NodePath("/root/Level/AllTerrain"))
	
func spawnEnemy():
	var rn = rng.randf()
	if(rn <= spawnChance * chanceMod):
		rn = rng.randf()
		var enemy
		if(spawnAtEdgeOfScreen):
			enemy = levelScript.spawnMarauder(rn <= gunmanSpawnChance)
			print("spawning instance successful")
			if(!canDropItems):
				enemy.itemDropChance = 0
		else:
			if(rn <= gunmanSpawnChance):
				enemy = prefabs[0].instantiate()
			else:
				enemy = prefabs[1].instantiate()
			get_node("/root/Level").add_child(enemy)
			if(enemy != null):
				enemy.global_position = global_position
				enemy.sentryMode = sentryMode
				if(!canDropItems):
					enemy.itemDropChance = 0
				print("spawning instance successful")
			else:
				print("spawning instance unsuccessful")
		if(enemy != null):
			var parent = get_parent()
			if(parent.has_method("passEnemy")):
				parent.passEnemy(enemy)
