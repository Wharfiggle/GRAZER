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
	structures.append(["res://Assets/FloorTiles/TilePool/StructureTiles/testCheckPoint.tscn", 3, 4]) #checkpoint
	structures.append(["res://Assets/FloorTiles/TilePool/StructureTiles/structure2.tscn", 2, 1])
	structures.append(["res://Assets/FloorTiles/TilePool/EmptyFloor1.tscn", 2, 2]) #test
	structures.append(["res://Assets/FloorTiles/TilePool/testTile.tscn", 2, 2]) #test
	
	#* ^ ADD NEW STRUCTURES HERE ^ *
	#sPathname is the path to the scene. Right click and click "Copy Path" in the explorer to get it
	#sWidth is the length along the x axis
	#sDepth is the length along the z axis
	
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
	var distance = player.position.distance_to(position)
	
	#Waits to instantiate scene until ready
	if(loading and ResourceLoader.load_threaded_get_status(pathname) == 3):
		var chunk = ResourceLoader.load_threaded_get(pathname)
		await get_tree().process_frame
		instance = chunk.instantiate()
		add_child(instance)
		scene = instance
		loading = false
		if(!loadedBefore):
			activateSpawners()
			loadedBefore = true
		loaded = true
	
	#Starts request to load scene when player is close enough
	if(distance <= renderRange * tileWidth and !loaded and !loading):
		ResourceLoader.load_threaded_request(pathname,"",false, ResourceLoader.CACHE_MODE_REUSE)
		loading = true
	#Unloads scene when player is far away enough
	elif(distance > (renderRange + 1) * tileWidth and scene != null):
		scene.queue_free()
		scene = null
		loaded = false

#Returns the path, width, and depth of structure with the id passed in
#static func retrieveStructureInfo(id):
#	var sPathname = ""
#	var sWidth = 0
#	var sDepth = 0
#
#	match[id]:
#		[1]: #Checkpoint
#			sPathname = "res://Assets/FloorTiles/TilePool/StructureTiles/testCheckPoint.tscn"
#			sWidth = 3
#			sDepth = 4
#		[2]:
#			sPathname = "res://Assets/FloorTiles/TilePool/StructureTiles/structure2.tscn"
#			sWidth = 2
#			sDepth = 1
#
#	return [sPathname, sWidth, sDepth]

func activateSpawners():
	#loop through children and find all the spawners
	#Then call their spawn function
	var children = instance.get_children()
	for c in children:
		#If child has spawn method, call it
		if(c.has_method("spawn")):
			c.spawn(spawnChanceMod, spawnPrefabs)
