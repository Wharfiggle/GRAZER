extends Spatial
#taken from https://github.com/NesiAwesomeneess/ChunkLoader/blob/main/ChunkLoading/World.gd

export (NodePath) var playerPath = "/root/Level/Ball"
var player

onready var chunkNode = preload("res://Assets/FloorTiles/ChunkNode.tscn")
onready var basicTile = preload("res://Assets/FloorTiles/basicFloorTile.tscn")

export (int) var renderDistance = 3
export (float) var tileWidth = 32.0
var currentChunk = Vector3()
var previousChunk = Vector3()
var chunkLoaded = false

export (bool) var circumnavigation = false
export (float) var revolution_distance = 8.0

onready var activeCoord = []
onready var activeChunks = []

func _ready(): 
	player = get_node(playerPath)
	print("player" + str(player))
	currentChunk = getPlayerChunk(player.transform.origin)
	loadChunk()

func _process(delta):
	#checks if player has left their current chunk and loads if they have
	currentChunk = getPlayerChunk(player.transform.origin)
	if(currentChunk != previousChunk):
		if(!chunkLoaded):
			print("loading chunks")
			#loadChunk()
	else:
		chunkLoaded = false;
	previousChunk = currentChunk

#converts the parameter coordinates into an smaller coord, 32,32 -> 1,1
func getPlayerChunk(pos):
	var chunkPos = Vector3()
	chunkPos.x = int(pos.x / tileWidth)
	chunkPos.z = int(pos.z / tileWidth)
	if(pos.x < 0):
		chunkPos.x -= 1
	if(pos.z < 0):
		chunkPos.z -= 1
	return chunkPos

func loadChunk():
	var renderBounds = (float(renderDistance)*2.0)+1.0
	var loadingCoord = []
	#if x = 0, then x+1 = 1
	#if render_bounds = 5 (render distance = 2) then 5/2 = 2.5, (round(2.5)) = 3
	#then 1 - 3 = -2 which is the x coord in the chunk space, this same principle is used
	#for the y axis as well.
	for x in range(renderBounds):
		for z in range(renderBounds):
			var _x  = (x+1) - (round(renderBounds/2.0)) + currentChunk.x
			var _z  = (z+1) - (round(renderBounds/2.0)) + currentChunk.z
			
			var chunkCoords = Vector3(_x, 0, _z)
			#the chunk key is the key the chunk will use to retreive data from the world save
			#it depends on the no of revolutions and the chunk coords
			var chunkKey = _get_chunk_key(chunkCoords)
			loadingCoord.append(chunkCoords)
			#loading chunks stores the coords that are in the new render chunk
			#this if statement makes sure that only the coords that are not already active are loaded
			if activeCoord.find(chunkCoords) == -1:
				var chunk = chunkNode.instance()
				chunk.transform.origin = chunkCoords * tileWidth
				activeChunks.append(chunk)
				activeCoord.append(chunkCoords)
				chunk.start(chunkKey)
				add_child(chunk)
	#deleting the chunks just makes an array of chunks that are in active chunks and not in the
	#chunks that are being loaded (loading coords), deleting chunks then deletes them from 
	#both the active chunk and coords array
	var deletingChunks = []
	for x in activeCoord:
		if loadingCoord.find(x) == -1:
			deletingChunks.append(x)
	for x in deletingChunks:
		var index = activeCoord.find(x)
		activeChunks[index].save()
		activeChunks.remove(index)
		activeChunks.remove(index)
	
	chunkLoaded = true

func _get_chunk_key(coords : Vector3):
	var key = coords
	if !circumnavigation:
		return key
	key.x = wrapf(coords.x, -revolution_distance, revolution_distance+1)
	return key
