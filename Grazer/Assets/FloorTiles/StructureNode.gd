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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if(pathname != null and !loaded):
#		print("loaded structure")
#		print(pathname)
#		var scene = load(pathname)
#
#		var instance = scene.instantiate()
#		add_child(instance)
#		loaded = true
	var distance = player.position.distance_to(position)
	#print(ResourceLoader.load_threaded_get_status(pathname))
	if(loading and ResourceLoader.load_threaded_get_status(pathname) == 3):
		#This function will freeze the game until the scene is fully loaded
		#But once loaded, it does return the reference to the scene that we need
		var chunk = ResourceLoader.load_threaded_get(pathname)
		await get_tree().process_frame
		var instance = chunk.instantiate()
		add_child(instance)
		#instance.position = position
		scene = instance
		loading = false
		loaded = true
		print("Added structure?")
	if(distance <= renderRange * tileWidth):
		#print("Should load this?!?!")
		pass

	if(distance <= renderRange * tileWidth and !loaded and !loading):
		ResourceLoader.load_threaded_request(pathname,"",false, ResourceLoader.CACHE_MODE_REUSE)
		loading = true
		print("Start loading")

	elif(distance > (renderRange + 1) * tileWidth and scene != null):
		scene.queue_free()
		scene = null
		loaded = false

func setStructureData(id):
	tileId = id
	var info = tileStructures.retrieveStructureInfo(tileId)
	pathname = info[0]
	width = info[1]
	depth = info[2]

#Returns the 
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
	
	
	
	
	return [sPathname, sWidth, sDepth]

