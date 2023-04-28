extends Node3D

class_name tileStructures

@onready var player = get_node("/root/Level/Player")

var tileWidth = 16
var tileId = 0

var pathname = ""
var width = 1
var depth = 1
var renderRange = 5
var alwaysRendered = false

var scene = null
var loaded = false
var loading = false
var loadedBefore = false
var instance

var spawnChanceMod = 1.0
var spawnPrefabs = []

static func retrieveStructureTypes() -> Array:
	var structures = []
	
	#sPathName, sWidth, sHeight
	structures.append(["res://Assets/FloorTiles/TilePool/StructureTiles/checkPoint.tscn", 2, 4]) #checkpoint middle
	structures.append(["res://Assets/FloorTiles/TilePool/StructureTiles/checkPointLeft.tscn", 4, 4]) #checkpoint left
	structures.append(["res://Assets/FloorTiles/TilePool/StructureTiles/checkPointRight.tscn", 4, 4]) #checkpoint right
#	structures.append(["res://Assets/FloorTiles/TilePool/StructureTiles/structure2.tscn", 2, 1])
#	structures.append(["res://Assets/FloorTiles/TilePool/StructureTiles/EmptyFloor1.tscn", 2, 2]) #test
	structures.append(["res://Assets/FloorTiles/TilePool/StructureTiles/testTile.tscn", 2, 2]) #test
	structures.append(["res://Assets/FloorTiles/TilePool/StructureTiles/cliffPit1.tscn", 1, 2]) #test
	#structures.append(["res://Assets/FloorTiles/TilePool/StructureTiles/cliffPitV2.tscn", 1, 1]) #test
	structures.append(["res://Assets/FloorTiles/TilePool/StructureTiles/rvTestStruct.tscn", 2, 1])
	structures.append(["res://Assets/FloorTiles/TilePool/StructureTiles/archway.tscn", 1, 1])
	structures.append(["res://Assets/FloorTiles/TilePool/StructureTiles/radioTower.tscn", 1, 1])
	structures.append(["res://Assets/FloorTiles/TilePool/StructureTiles/structAmbush1.tscn", 1, 1])
	structures.append(["res://Assets/FloorTiles/TilePool/StructureTiles/road s 1.tscn", 1, 3])
	structures.append(["res://Assets/FloorTiles/TilePool/StructureTiles/organCactus1.tscn", 1, 1])
	structures.append(["res://Assets/FloorTiles/TilePool/StructureTiles/building test.tscn", 2, 3])
	structures.append(["res://Assets/FloorTiles/TilePool/StructureTiles/cliffPitV2.tscn", 1, 1])
	
	# * ^ ADD NEW STRUCTURES HERE ^ *
	#sPathname is the path to the scene. Right click and click "Copy Path" in the explorer to get it
	#sWidth is the length along the x axis
	#sDepth is the length along the z axis
	
	# "Should my tile be a Chunk or a Structure?":
	#If your tile is more than 1x1, it should be a Structure.
	#If your tile is 1x1, it can be a Structure, but only if it is significant and shouldn't be spawned a ton.
	#If your tile spawns items or has a high probability to spawn enemies, it should be a structure.
	#Your tile should be a Chunk if you want it to pop up all over the place.
	#You can put enemy spawns in Chunks but they should have a low spawnChance.
	
	return structures
	
#Just a setter that fills out variables from the id.
func setStructureData(id:int, structureTypes:Array = []) -> Array:
	tileId = id
	var structures = structureTypes
	if(structureTypes.is_empty()):
		structures = tileStructures.retrieveStructureTypes()
	var info = structures[tileId]
	pathname = info[0]
	width = info[1]
	depth = info[2]
	return structures

func setSpawnerVariables(inSpawnChanceMod:float, inSpawnPrefabs:Array):
	spawnChanceMod = inSpawnChanceMod
	spawnPrefabs = inSpawnPrefabs

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var tileCenter = position / tileWidth
	tileCenter.x += width / 2.0
	tileCenter.z -= depth / 2.0
	var distance = abs(tileCenter - terrainController.getPlayerChunk(player.position))

#	if(tileId == 0):
#		if((tileCenter).x == terrainController.getPlayerChunk(player.position).x):
#			print("MATCHED X")
#		if((tileCenter).z == terrainController.getPlayerChunk(player.position).z):
#			print("MATCHED Z")
	
	#Waits to instantiate scene until ready
	if(loading and ResourceLoader.load_threaded_get_status(pathname) == 3):
		var chunk = ResourceLoader.load_threaded_get(pathname)
		await get_tree().process_frame
		instance = chunk.instantiate()
		SceneCounter.structureScenes += 1
		add_child(instance)
		scene = instance
		loading = false
		if(!loadedBefore):
			activateSpawners()
			loadedBefore = true
		loaded = true
	
	#Starts request to load scene when player is close enough
	var inRange = distance.x < (width / 2 + 3) && distance.z < (depth / 2 + 3)
	var outOfRange = distance.x > (width / 2 + 4) || distance.z > (depth / 2 + 4)
	if(inRange && !loaded && !loading):
		print("LOAD STRUCTURE")
		#if(tileId == 0):
		#	print("LOADING CHECKPOINT: distance.x: " + str(distance.x) + " < " + str(width / 2 + 2))
		ResourceLoader.load_threaded_request(pathname,"",false, ResourceLoader.CACHE_MODE_REUSE)
		loading = true
	#Unloads scene when player is far away enough
	#elif(distance > (renderRange + 1) * tileWidth and scene != null):
	elif(outOfRange && scene != null):
		print("UNLOAD STRUCTURE")
		#if(tileId == 0):
		#	print("UNLOADING CHECKPOINT: distance.x: " + str(distance.x) + " > " + str(width / 2 + 3))
		scene.queue_free()
		SceneCounter.structureScenes -= 1
		scene = null
		loaded = false

func activateSpawners():
	#loop through children and find all the spawners
	#Then call their spawn function
	var children = instance.get_children()
	for c in children:
		#If child has spawn method, call it
		if(c.has_method("spawn")):
			c.spawn(spawnChanceMod, spawnPrefabs)
