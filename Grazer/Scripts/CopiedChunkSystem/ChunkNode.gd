extends Spatial
export (NodePath) var WorldSavePath = "/Level/AllTerrain/WorldSave"
var worldSave 


var chunkCoords = Vector3()
var chunkData = []

func _ready():
	worldSave = get_node(WorldSavePath)
	

func start(_chunkCoords):
	print(WorldSavePath)
	print("t:" + str(worldSave))
	
	chunkCoords = _chunkCoords
	print("_chunkCoords is " + str(_chunkCoords))
	print(worldSave.loadedCoords)
	if(worldSave.loadedCoords.find(_chunkCoords) == -1):
		worldSave.addChunk(_chunkCoords)
	else:
		chunkData = worldSave.retriveData(chunkCoords)
		#modulate = chunkData[0]

func save():
	worldSave.saveChunk(chunkCoords, chunkData)
	queue_free()
