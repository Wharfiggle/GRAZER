extends Node3D

var chunkCoords = Vector3()
var chunkData = []

#chunkNode has basicFloor attached to it, which technically means that it has no base data
#needs to have a function to instance its own chunk tile.


func start(_chunkCoords):
	chunkCoords = _chunkCoords
	#print("_chunkCoords is " + str(_chunkCoords))
	if(WorldSave.loadedCoords.find(_chunkCoords) == -1):
		#chunkData.append()
		#var chunkPath = calcChunk(chunkCoords)
		#TODO: add a way to save the chunkPath to the chunkData
		#I think chunkData can be treated as an array of arrays
		#which is why it says chunkData[0] down there.
		WorldSave.addChunk(_chunkCoords)
	else:
		chunkData = WorldSave.retriveData(chunkCoords)
		#modulate = chunkData[0]

func save():
	WorldSave.saveChunk(chunkCoords, chunkData)
	queue_free()

func calcChunk(chunkCoords) -> void:
	#system for choosing a chunk from the list
	print("Calculate a chunk path")
