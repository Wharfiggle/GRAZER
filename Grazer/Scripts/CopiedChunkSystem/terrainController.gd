extends Node3D
#taken from https://github.com/NesiAwesomeneess/ChunkLoader/blob/main/ChunkLoading/World.gd

var playerPath = NodePath("/root/Level/Player")
var player
@onready var camera = get_node(NodePath("/root/Level/Camera3D"))
@onready var enemyPrefab = preload("res://Prefabs/Enemy.tscn")

@onready var chunkNode = preload("res://Assets/FloorTiles/ChunkNode.tscn")

var renderDistance = 2
var tileWidth = 16.0
var currentChunk = Vector3()
var previousChunk = Vector3()
var chunkLoaded = false

var circumnavigation = false
var revolution_distance = 8.0

@onready var activeCoord = []
@onready var activeChunks = []

var numLevels
#var mapWidth is set in ChunkNode.gd
@export var levelLength = 15 #How many tiles until a checkpoint is set
var structures = []
var structPerLevel = 5
var checkLength = null
var checkWidth = null

func _ready(): 
	checkLength = tileStructures.retrieveStructureInfo(1)[1] #Gets length of checkpoints
	checkLength = tileStructures.retrieveStructureInfo(1)[2] #Gets width
	player = get_node(playerPath)
	currentChunk = getPlayerChunk(player.transform.origin)
	loadChunk()

func _process(_delta):
	if(camera == null):
		camera = get_node(NodePath("/root/Level/Camera3D"))
	if(Input.is_action_just_pressed("debug4") || Input.is_action_just_pressed("debug5")):
		#screen height and width in units, 15.0 = camera.size()
		var camSize = 15.0
		if(camera != null):
			camSize = camera.size
		var scrHei = camSize / cos(55.0 * PI / 180.0)
		var scrWid = camSize / 9.0 * 16.0 #only works with 16:9 aspect ratio
		var enemy = enemyPrefab.instantiate()
		var type = enemy.enemyTypes.gunman
		if(Input.is_action_just_pressed("debug5")):
			type = enemy.enemyTypes.thief
		enemy.marauderType = type
		var horOrVert = randi_range(0, 1)
		var topOrBot = randi_range(0, 1)
		if(topOrBot == 0): topOrBot = -1
		if(horOrVert == 0):
			enemy.position = Vector3(
				topOrBot * (scrWid / 2.0 + 2), 1, 
				randf_range(-scrHei / 2.0, scrHei / 2.0))
		else:
			enemy.position = Vector3(
				randf_range(-scrWid / 2.0, scrWid / 2.0), 1, 
				topOrBot * (scrHei / 2.0 + 2))
		enemy.position = player.position + Vector3(
			cos(-PI/4.0) * enemy.position.x - sin(-PI/4.0) * enemy.position.z, 0,
			sin(-PI/4.0) * enemy.position.x + cos(-PI/4.0) * enemy.position.z)
		get_node(NodePath("/root/Level")).add_child(enemy)
	
	#checks if player has left their current chunk and loads if they have
	currentChunk = getPlayerChunk(player.transform.origin)
	if(currentChunk != previousChunk):
		if(!chunkLoaded):
			#semaphore.post()
			loadChunk()
	else:
		chunkLoaded = false;
	previousChunk = currentChunk

#converts the parameter coordinates into an smaller coord, 16,16 -> 1,1
func getPlayerChunk(pos):
	var chunkPos = Vector3()
	chunkPos.x = int(pos.x / tileWidth)
	chunkPos.y = int(0)
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
				var chunk = chunkNode.instantiate()
				chunk.transform.origin = chunkCoords * tileWidth
				activeChunks.append(chunk)
				activeCoord.append(chunkCoords)
				add_child(chunk)
				chunk.start(chunkKey)

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
		activeChunks.remove_at(index)
		activeCoord.remove_at(index)
	
	chunkLoaded = true

func _get_chunk_key(coords : Vector3):
	var key = coords
	key.y = 0
	if !circumnavigation:
		return key
	key.x = wrapf(coords.x, -revolution_distance, revolution_distance+1)
	return key

#Function that is called once at game start to pick locations for structures,
#reserve empty space in the regular chunk system for them (so they don't overlap normal tiles)
#and places the StructureNodes that load in the structure when the play gets close enough
func generateStructures():
	#Loop for levels
	for l in numLevels:
		#Generate the check points
		if(l < numLevels):
			var placed = false
			var failed = false
			var loops = 20
			var origin = Vector3()
			#TODO Maybe turn below loop into a function?
			while(!placed and !failed):
				origin.x = -1 + checkWidth / 2 
				origin.y = 0
				origin.z = levelLength * (l + 1) - checkLength
				placed = checkPlacement(1, _get_chunk_key(origin))
				#Only loops limited time to prevent 
				loops -= 1
				if(loops <= 0):
					print("Failed to place structure id: " + str(1))
					failed = true
			
			#If it found valid coordinates, proceed to adding the structure
			if(!failed):
				addStructure(1, _get_chunk_key(origin))
			
		else:
			#For the last level, generates the final pasture, instead of a checkpoint
			#TODO ADD FINAL PASTURE 
			pass
		
		for c in structPerLevel:
			#Generate normal structures:
			#Pick a random origin point and id
			#Check if the placement would work
			#If it does, place it and reserve empty space
			#If not, try a few more times
			
			#TODO ADD NORMAL STRUCTURE GENERATION
			
			
			pass
	
	
	pass

#Loop through all generated structures and checks if the 
#new structure would overlap
func checkPlacement(id, coords) -> bool:
	#coords are in tile coordinates
	for c in structures:
		if(checkOverlap(id, coords, c[0], c[1])):
			return false
	return true

#Helper function to check if two structures would overlap
func checkOverlap(idA, coordsA, idB, coordsB) -> bool:
	
	#TODO ADD MATH TO CHECK STRUCTURE OVERLAP
	
	return false

#Adds valid structure to the structure array, reserves the empty space, and places the node
func addStructure(id, coords):
	var data = tileStructures.retrieveStructureInfo(id)
	
	#Add structure to structure array
	structures.append([id, coords, data[1], data[2]])
	#[id, coordinates, width, depth]
	
	#Reserve empty chunks
	for x in data[1]:
		for z in data[2]:
			var tVec = Vector3(coords.x + x, 0, coords.z + z)
			setEmptyChunk(tVec)
	
	#Places structure node in correct place on map
	
	#TODO ADD STRUCTURE NODE PLACEMENT
	

#Sets a chunk as empty
func setEmptyChunk(coords : Vector3):
	#coords are in tile coordinates
	if(WorldSave.loadedCoords.find(coords) != -1):
		return
	WorldSave.addChunk(coords)
	var data = []
	data.append("")
	WorldSave.saveChunk(coords,data)
