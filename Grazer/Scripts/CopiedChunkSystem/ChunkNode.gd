extends Node3D

var chunkCoords = Vector3()
var chunkData = []

#chunkNode has basicFloor attached to it, which technically means that it has no base data
#needs to have a function to instance its own chunk tile.


func start(_chunkCoords):
	chunkCoords = _chunkCoords
	#If this chunk has not been loaded before
	if(WorldSave.loadedCoords.find(_chunkCoords) == -1):
		chunkData.append(calcChunk(chunkCoords))
		
		#chunkData is the data variable for everything in a chunk, so it'll need to
		#save the chunk path and anything else
		
		#Adding this chunk node to the world save array
		WorldSave.addChunk(_chunkCoords)
	
	#else it has been loaded before
	else:
		chunkData = WorldSave.retriveData(chunkCoords)
	#print("Chunk data" + str(chunkCoords) + ": " + str(chunkData[0]))
	
	var chunk = load(chunkData[0])
	var instance = chunk.instantiate()
	add_child(instance)

func save():
	WorldSave.saveChunk(chunkCoords, chunkData)
	queue_free()

#custom function for choosing a chunk from our library based on the coordinates
func calcChunk(_chunkCoords) -> String:
	#system for choosing a chunk from the list
	match [randi_range(1,4)]:
		[1]:
			return "res://Assets/FloorTiles/basicFloorTile.tscn"
		[2]:
			return "res://Assets/FloorTiles/tile1.tscn"
		[3]:
			return "res://Assets/FloorTiles/tile2.tscn"
		[4]:
			return "res://Assets/FloorTiles/pathingTestTile.tscn"
	return "res://Assets/FloorTiles/basicFloorTile.tscn"
