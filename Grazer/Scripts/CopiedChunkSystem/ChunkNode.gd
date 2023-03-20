extends Node3D

var chunkCoords = Vector3()
var chunkData = []

#chunkNode has basicFloor attached to it, which technically means that it has no base data
#needs to have a function to instance its own chunk tile.


func start(_chunkCoords):
	chunkCoords = _chunkCoords
	#If this chunk has not been loaded before
	if(WorldSave.loadedCoords.find(_chunkCoords) == -1):
		chunkData.append(randi_range(1,1000))
		#var chunkPath = calcChunk(chunkCoords)
		#TODO: add a way to save the chunkPath to the chunkData
		#chunkData is the data variable for everything in a chunk, so it'll need to
		#save the chunk path and anything else
		
		#Adding this chunk node to the world save array
		WorldSave.addChunk(_chunkCoords)
		
	#else it has been loaded before
	else:
		chunkData = WorldSave.retriveData(chunkCoords)
		#modulate = chunkData[0] #Used for setting the color of a 2d sprite (irrelevent)
	print("Chunk data" + str(chunkCoords) + ": " + str(chunkData[0]))

func save():
	WorldSave.saveChunk(chunkCoords, chunkData)
	queue_free()

#custom function for choosing a chunk from our library based on the coordinates
func calcChunk(chunkCoords) -> void:
	#system for choosing a chunk from the list
	print("Calculate a chunk path")
