extends Spatial




var chunkCoords = Vector3()
var chunkData = []

func start(_chunkCoords):
	chunkCoords = _chunkCoords
	#print("_chunkCoords is " + str(_chunkCoords))
	if(WorldSave.loadedCoords.find(_chunkCoords) == -1):
		WorldSave.addChunk(_chunkCoords)
	else:
		chunkData = WorldSave.retriveData(chunkCoords)
		#modulate = chunkData[0]

func save():
	WorldSave.saveChunk(chunkCoords, chunkData)
	queue_free()
