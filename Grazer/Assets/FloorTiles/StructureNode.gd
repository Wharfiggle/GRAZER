extends Node3D

class_name tileStructures

@onready var player = get_node("/root/Level/Player")

#*UPDATE THIS VARIABLE WHEN ADDING NEW STRUCTURES*
const numStuctures = 4

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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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

#Just a setter that fills out variables from the id.
func setStructureData(id):
	tileId = id
	var info = tileStructures.retrieveStructureInfo(tileId)
	pathname = info[0]
	width = info[1]
	depth = info[2]

#Returns the path, width, and depth of structure with the id passed in
static func retrieveStructureInfo(id):
	
	var sPathname = ""
	var sWidth = 0
	var sDepth = 0
	
	match[id]:
		[1]: #Checkpoint
			sPathname = "res://Assets/FloorTiles/TilePool/StructureTiles/testCheckPoint.tscn"
			sWidth = 3
			sDepth = 4
			
		[2]:
			sPathname = "res://Assets/FloorTiles/TilePool/StructureTiles/structure2.tscn"
			sWidth = 2
			sDepth = 1
		[3]:
			sPathname = "res://Assets/FloorTiles/EmptyFloor1.tscn"
			sWidth = 2
			sDepth = 2
		[4]:
			sPathname = "res://Assets/FloorTiles/testTile.tscn"
			sWidth = 2
			sDepth = 2
	
	#* ^ ADD NEW STRUCTURES HERE ^ *
	#The number in the "[]" is the id number. Just increment it 1 higher than the last one
	#sPathname is the path to the scene. Right click and click "Copy Path" in the explorer to get it
	#sWidth is the length along the x axis
	#sDepth is the length along the z axis
	#* REMEMBER TO UPDATE const numStructures UP ON LINE 8 *
	
	return [sPathname, sWidth, sDepth]

func activateSpawners():
	#loop through children and find all the spawners
	#Then call their spawn function
	var children = instance.get_children()
	for c in children:
			#Catch all for spawner names
		if(c.name == "Spawner" or c.name == "spawnerNode" or
		c.name == "ItemSpawner" or c.name == "EnemySpawner"):
			c.spawn()
