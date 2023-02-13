extends Spatial

var chunkCoords = Vector3()
var chunkData = []

func start(_chunkCoords):
	chunkCoords = _chunkCoords
	
	if(WorldSave.loadedCoords.find(_chunkCoords) == -1):
		WorldSave.addChunk(_chunkCoords)
	else:
		chunk_data = worldSave.retriveData(chunkCoords)
		modulate = chunkData[0]

