extends Node3D

@onready var vParent = get_node("/root/Level/AllTerrain")
var chunkCoords = Vector3()
var chunkData = []

var loading = false

var mapWidth = 5

func start(_chunkCoords):
	chunkCoords = _chunkCoords
	#If this chunk has not been loaded before
	if(WorldSave.loadedCoords.find(_chunkCoords) == -1):
		chunkData.append(calcChunk(chunkCoords))
		
		#Adding this chunk node to the world save array
		WorldSave.addChunk(_chunkCoords)
	
	#else it has been loaded before
	else:
		chunkData = WorldSave.retriveData(chunkCoords)
	
	if(chunkData[0] == ""):
		print("Chunk " + str(position) + " is empty")
		return
	
	#Theoretically this doesn't need to be called if its already been loaded before
	ResourceLoader.load_threaded_request(chunkData[0],"",false, ResourceLoader.CACHE_MODE_REUSE)
	
	#This function returns 1 if in progress or 3 if done
	#It needs to be used to pause this script until 3 is returned, possibly using a semaphore
	#print(ResourceLoader.load_threaded_get_status(chunkData[0]))
	loading = true
	

func _process(delta):
	#Because if we try instantiate the scene while its not done it freezes the game
	#Instead this function tries to check every frame if its done before attempting
	
	if(loading):
		if(chunkData[0] == ""):
			loading = false
		#print(ResourceLoader.load_threaded_get_status(chunkData[0]))
		elif(ResourceLoader.load_threaded_get_status(chunkData[0]) == 3):
			#This function will freeze the game until the scene is fully loaded
			#But once loaded, it does return the reference to the scene that we need
			var chunk = ResourceLoader.load_threaded_get(chunkData[0])
			await get_tree().process_frame
			var instance = chunk.instantiate()
			add_child(instance)
			loading = false


func save():
	WorldSave.saveChunk(chunkCoords, chunkData)
	queue_free()


#custom function for choosing a chunk from our library based on the coordinates
func calcChunk(_chunkCoords) -> String:
	#system for choosing a chunk from the list
	var pathName = "res://Assets/FloorTiles/TilePool/"
	
	if(chunkCoords.x == mapWidth):
		pathName += "WallTiles/wall1d"
	elif(chunkCoords.x == -mapWidth):
		pathName += "WallTiles/wall1b"
	else:
		pathName += "BasicTiles/basic"
		pathName += str(randi_range(1,4))
	pathName += ".tscn"
	return pathName

func setVParent(parent):
	vParent = parent
