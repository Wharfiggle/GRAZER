extends Node3D

class_name tileStructures

@onready var player = get_node("/root/Level/Player")

var tileId = 0

var pathname = ""
var width = 1
var depth = 1
var renderRange = 3
var alwaysRendered = false

var scene

var loading = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var distance = player.position.distance_to(position)
	if(ResourceLoader.load_threaded_get_status(pathname) == 3):
		#This function will freeze the game until the scene is fully loaded
		#But once loaded, it does return the reference to the scene that we need
		var chunk = ResourceLoader.load_threaded_get(pathname)
		await get_tree().process_frame
		var instance = chunk.instantiate()
		add_child(instance)
		scene = instance
		loading = false
	
	if(distance <= renderRange and scene == null):
		ResourceLoader.load_threaded_request(pathname,"",false, ResourceLoader.CACHE_MODE_REUSE)
		
	elif(distance > renderRange + 1 and scene != null):
		scene.queue_free()
		

func setStructureData(id):
	tileId = id
	var info = retrieveStructureInfo(tileId)
	pathname = info[0]
	width = info[1]
	depth = info[2]

#Returns the 
static func retrieveStructureInfo(id):
	
	var pathname = ""
	var width = 0
	var depth = 0
	
	match[id]:
		[1]: #Checkpoint
			pathname = "res://Assets/FloorTiles/TilePool/StructureTiles/testCheckPoint.tscn"
			width = 3
			depth = 4
			
		[2]:
			pathname = "res://Assets/FloorTiles/TilePool/StructureTiles/structure2.tscn"
			width = 2
			depth = 1
			pass
	
	
	
	
	return [pathname, width, depth]

