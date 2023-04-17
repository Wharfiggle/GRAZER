extends Node3D
class_name chunkTiles
@onready var vParent = get_node("/root/Level/AllTerrain")
var chunkCoords = Vector3()
var chunkData = []

var loading = false
var loadedBefore = false
var instance
var mapWidth = terrainController.mapWidth

var spawnChanceMod = 1.0
var spawnPrefabs = []

static func retrieveChunkTypes() -> Array:
	var chunks = []
	
	chunks.append("res://Assets/FloorTiles/TilePool/BasicTiles/basic1.tscn")
	chunks.append("res://Assets/FloorTiles/TilePool/BasicTiles/basic2.tscn")
	chunks.append("res://Assets/FloorTiles/TilePool/BasicTiles/basic3.tscn")
	chunks.append("res://Assets/FloorTiles/TilePool/BasicTiles/basic4.tscn")
	
	# * ^ ADD NEW CHUNKS HERE ^ *
	#The string is the path to the scene. Right click and click "Copy Path" in the explorer to get it
	
	# "Should my tile be a Chunk or a Structure?":
	#If your tile is more than 1x1, it should be a Structure.
	#If your tile is 1x1, it can be a Structure, but only if it is significant and shouldn't be spawned a ton.
	#If your tile spawns items or has a high probability to spawn enemies, it should be a structure.
	#Your tile should be a Chunk if you want it to pop up all over the place.
	#You can put enemy spawns in Chunks but they should have a low spawnChance.
	
	return chunks

func start(_chunkCoords, chunkTypes:Array = []) -> Array:
	chunkCoords = _chunkCoords
	if(chunkTypes.is_empty()):
		chunkTypes = chunkTiles.retrieveChunkTypes()
	#If this chunk has not been loaded before
	if(WorldSave.loadedCoords.find(_chunkCoords) == -1):
		#Calculates a scene path and adds it to the data array
		chunkData.append(calcChunk(chunkCoords, chunkTypes))
		
		#Adding this chunk node to the world save array
		WorldSave.addChunk(_chunkCoords)
		loadedBefore = false
	
	
	#else it has been loaded before
	else:
		chunkData = WorldSave.retriveData(chunkCoords)
		loadedBefore = true
	
	if(chunkData[0] == ""):
		#print("Chunk " + str(position) + " is empty")
		return chunkTypes
	
	#Theoretically this doesn't need to be called if its already been loaded before
	if(!ResourceLoader.has_cached(chunkData[0])):
		ResourceLoader.load_threaded_request(chunkData[0],"",false, ResourceLoader.CACHE_MODE_REUSE)
	
	#This function returns 1 if in progress or 3 if done
	#It needs to be used to pause this script until 3 is returned, possibly using a semaphore
	#print(ResourceLoader.load_threaded_get_status(chunkData[0]))
	loading = true
	
	return chunkTypes

func _process(_delta):
	#Because if we try instantiate the scene while its not done it freezes the game
	#Instead this function tries to check every frame if its done before attempting
	
	if(loading):
		#print(ResourceLoader.load_threaded_get_status(chunkData[0]))
		if(chunkData[0] == ""):
			loading = false
		elif(ResourceLoader.load_threaded_get_status(chunkData[0]) == 3):
			#This function will freeze the game until the scene is fully loaded
			#But once loaded, it does return the reference to the scene that we need
			#var chunk = ResourceLoader.load_threaded_get(chunkData[0])
			var chunk = ResourceLoader.load(chunkData[0],"",1)
			await get_tree().process_frame
			instance = chunk.instantiate()
			SceneCounter.chunkScenes += 1
			add_child(instance)
			#Spawn everything in the chunk
			if(!loadedBefore):
				activateSpawners()
				loadedBefore = true
			loading = false
		elif(ResourceLoader.has_cached(chunkData[0])):
			print("Chunk is cached, but not thread loaded")
		else:
			print("Chunk wasn't preloaded")

func setSpawnerVariables(inSpawnChanceMod:float, inSpawnPrefabs:Array):
	spawnChanceMod = inSpawnChanceMod
	spawnPrefabs = inSpawnPrefabs

func save():
	WorldSave.saveChunk(chunkCoords, chunkData)
	queue_free()
	SceneCounter.chunkNodes -= 1
	if(chunkData[0] != ""):
		SceneCounter.chunkScenes -= 1


#custom function for choosing a chunk from our library based on the coordinates
func calcChunk(_chunkCoords, chunkTypes:Array = []) -> String:
	#system for choosing a chunk from the list
	
	if(chunkTypes.is_empty()):
		chunkTypes = retrieveChunkTypes()

	var pathName = ""
	if(chunkCoords.z == 2):
		pathName = "res://Assets/FloorTiles/TilePool/WallTiles/cliffSide1.tscn"
	elif(chunkCoords.z > 2):
		pathName = ""
	elif(chunkCoords.x == mapWidth):
		pathName = "res://Assets/FloorTiles/TilePool/WallTiles/wall1d.tscn"
	elif(chunkCoords.x == -mapWidth):
		pathName = "res://Assets/FloorTiles/TilePool/WallTiles/wall1b.tscn"
	elif(chunkCoords.x > mapWidth):
		pathName = ""
	elif(chunkCoords.x < -mapWidth):
		pathName = ""
	else:
		var rn = randi_range(0, chunkTypes.size() - 1)
		pathName = chunkTypes[rn]
		
	return pathName

func activateSpawners():
	#loop through children and find all the spawners
	#Then call their spawn function
	var children = instance.get_children()
	for c in children:
		#Call spawn() on all spawners
		if(c.has_method("spawn")):
			c.spawn(spawnChanceMod, spawnPrefabs)

func setVParent(parent):
	vParent = parent

