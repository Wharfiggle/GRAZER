extends Node3D
#taken from https://github.com/NesiAwesomeneess/ChunkLoader/blob/main/ChunkLoading/World.gd
class_name terrainController

var playerPath = NodePath("/root/Level/Player")
var player
@onready var camera = get_node(NodePath("/root/Level/Camera3D"))
@onready var gunmanPrefab = preload("res://Prefabs/Gunman.tscn")
@onready var thiefPrefab = preload("res://Prefabs/Thief.tscn")

@onready var chunkNode = preload("res://Assets/FloorTiles/ChunkNode.tscn")
@onready var structureNode = preload("res://Assets/FloorTiles/StructureNode.tscn")
@onready var structureTypes = tileStructures.retrieveStructureTypes()
var chunkTypes = chunkTiles.retrieveChunkTypes()


const chunkPrefabs = [
	preload("res://Assets/FloorTiles/TilePool/BasicTiles/basic1.tscn"),
	preload("res://Assets/FloorTiles/TilePool/BasicTiles/basic2.tscn"),
	#preload("res://Assets/FloorTiles/TilePool/BasicTiles/basic2_1.tscn"),
	preload("res://Assets/FloorTiles/TilePool/BasicTiles/basic2_3.tscn"),
	#preload("res://Assets/FloorTiles/TilePool/BasicTiles/basic2_1.tscn"),
	preload("res://Assets/FloorTiles/TilePool/BasicTiles/basic3.tscn"),
	#preload("res://Assets/FloorTiles/TilePool/BasicTiles/basic4.tscn"),
	preload("res://Assets/FloorTiles/TilePool/BasicTiles/basic5.tscn")
]
static func getChunkPrefabs():
	return chunkPrefabs
const structurePrefabs = [
	preload("res://Assets/FloorTiles/TilePool/StructureTiles/testCheckPoint.tscn"), #checkpoint
	preload("res://Assets/FloorTiles/TilePool/StructureTiles/structure2.tscn"),
	preload("res://Assets/FloorTiles/TilePool/StructureTiles/EmptyFloor1.tscn"), #test
	preload("res://Assets/FloorTiles/TilePool/StructureTiles/testTile.tscn"), #test
	preload("res://Assets/FloorTiles/TilePool/StructureTiles/cliffPit1.tscn"), #test
	preload("res://Assets/FloorTiles/TilePool/StructureTiles/cliffPitV2.tscn"), #test
	preload("res://Assets/FloorTiles/TilePool/StructureTiles/rvTestStruct.tscn"),
	preload("res://Assets/FloorTiles/TilePool/BasicTiles/basic4.tscn")
]
static func getStructurePrefabs():
	return structurePrefabs
const wallPrefabs = [
	preload("res://Assets/FloorTiles/TilePool/WallTiles/cliffSide2.tscn"),
	preload("res://Assets/FloorTiles/TilePool/WallTiles/cliffSide3.tscn"),
	preload("res://Assets/FloorTiles/TilePool/WallTiles/canyonWall1.tscn")
]
static func getWallPrefabs():
	return wallPrefabs
#I can't actually figure out how to implement this properly right now but
#this is our last resort if tiles keep refusing to load.

var renderDistance = 2
const tileWidth = 16.0
var currentChunk = Vector3()
var previousChunk = Vector3()
var chunkLoaded = false

var circumnavigation = false
var revolution_distance = 8.0

@onready var activeCoord = []
@onready var activeChunks = []

var numLevels = 3
const mapWidth = 5
@export var levelLength = 15 #How many tiles until a checkpoint is set
var structures = []
var structPerLevel = 10
var checkLength = 4
var checkWidth = 3

#chance modifier for spawners on each chunk/structure. Increases as player progresses
var spawnChanceMod = 1.0

func _ready():
	checkWidth = structureTypes[1][1] #Gets width of checkpoints
	checkLength = structureTypes[1][2] #Gets length
	preloadTiles()
	generateStructures()
	
	player = get_node(playerPath)
	currentChunk = terrainController.getPlayerChunk(player.transform.origin)
	loadChunk()

func spawnMarauder(gunman:bool):
	#screen height and width in units, 15.0 = camera.size()

	var camSize = 15.0
	if(camera != null):
		camSize = camera.size
	var scrHei = camSize / cos(55.0 * PI / 180.0)
	var scrWid = camSize / 9.0 * 16.0 #only works with 16:9 aspect ratio
	var enemy
	if(!gunman):
		enemy = thiefPrefab.instantiate()
	else:
		enemy = gunmanPrefab.instantiate()
	SceneCounter.marauders += 1
	get_node(NodePath("/root/Level")).add_child(enemy)
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

func _process(_delta):
	if(camera == null):
		camera = get_node(NodePath("/root/Level/Camera3D"))
	if(Input.is_action_just_pressed("debug4")):
		spawnMarauder(true)
	if(Input.is_action_just_pressed("debug5")):
		spawnMarauder(false)
	
	#checks if player has left their current chunk and loads if they have
	currentChunk = terrainController.getPlayerChunk(player.transform.origin)
	if(currentChunk != previousChunk):
		if(!chunkLoaded):
			loadChunk()
			pass
		print("Player entered chunk " +str(terrainController.getPlayerChunk(player.transform.origin)))
	else:
		chunkLoaded = false;
	previousChunk = currentChunk


#converts the parameter coordinates into an smaller coord, 16,16 -> 1,1
static func getPlayerChunk(pos):
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
				SceneCounter.chunkNodes += 1
				chunk.setSpawnerVariables(spawnChanceMod, [gunmanPrefab, thiefPrefab])
				chunk.transform.origin = chunkCoords * tileWidth
				activeChunks.append(chunk)
				activeCoord.append(chunkCoords)
				add_child(chunk)
				if(chunkTypes == null):
					chunkTypes = chunk.start(chunkKey)
				else:
					chunk.start(chunkKey, chunkTypes)

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

#Does essentially nothing because circumnavigation is disabled
func _get_chunk_key(coords : Vector3):
	var key = coords
	key.y = 0
	if !circumnavigation:
		return key
	#key.x = wrapf(coords.x, -revolution_distance, revolution_distance+1)
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
			var origin = Vector3()
			origin.x = -checkWidth / 2 
			origin.y = 0
			origin.z = -(levelLength * (l + 1) + (l * 5) - checkLength)
			#origin *= tileWidth
			placed = checkPlacement(1, origin * tileWidth)
			#If it found valid coordinates, proceed to adding the structure
			if(placed):
				addStructure(0, origin)
				print("added checkpoint at " + str(origin))
			else:
				print("failed to place checkpoint " + str(l + 1))
			
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
			
			var placed = false
			var failed = false
			var loops = 50
			var origin = Vector3()
			#TODO Maybe change from complete random to a more balenced spread of structures?
			var id = randi_range(1, structureTypes.size() - 1)
			var structureInfo = structureTypes[id]
			while(!placed and !failed):
				origin.x = randi_range(-mapWidth + 1 , mapWidth - structureInfo[1])
				origin.y = 0
				#+3 is in hopes of preventing overlap with the checkpoints
				origin.z = randi_range(-l * levelLength,
				-(((l + 1) * levelLength) + (l * 5) + 3))
				if(origin.z >= -1):
					origin.z = -2
				
				#origin *= tileWidth
				placed = checkPlacement(id, origin * tileWidth)
				
				#Only loops limited time to prevent infinite looping
				loops -= 1
				if(loops <= 0):
					print("Failed to place structure id: " + str(id))
					failed = true
			#If it found valid coordinates, proceed to adding the structure
			if(!failed):
				addStructure(id, origin)
			

#Loop through all generated structures and checks if the 
#new structure would overlap
func checkPlacement(id, worldCoords) -> bool:
	for c in structures:
		if(checkOverlap(id, worldCoords, c[0], c[1] * tileWidth)):
			return false
	return true

#Helper function to check if two structures would overlap. Returns false, if they don't.
func checkOverlap(idA, coordsA, idB, coordsB) -> bool:
	var structureA = structureTypes[idA]
	var structureB = structureTypes[idB]
	var widthA = structureA[1] * tileWidth
	var depthA = structureA[2] * tileWidth
	var widthB = structureB[1] * tileWidth
	var depthB = structureB[2] * tileWidth
	
	var extraTiles = 0 #Variable for adding extra spaces around structures
	if(coordsA.x > coordsB.x + widthB + extraTiles):
		return false
	if(extraTiles + coordsA.x + widthA < coordsB.x):
		return false
	if(coordsA.z < coordsB.z - depthB - extraTiles):
		return false
	if(-extraTiles + coordsA.z - depthA > coordsB.z):
		return false
	return true

#Adds valid structure to the structure array, reserves the empty space, and places the node
func addStructure(id, chunkCoords):
	var data = structureTypes[id]
	#print("Placed structure " + str(id) + " at " + str(chunkCoords))
	#Add structure to structure array
	structures.append([id, chunkCoords, data[1], data[2]])
	#[id, coordinates, width, depth]
	
	#Reserve empty chunks
	for x in data[1]:
		for z in data[2]:
			var tVec = Vector3(chunkCoords.x + x, 0, chunkCoords.z - z)
			tVec *= tileWidth
			setEmptyChunk(tVec)
	
	#Places structure node in correct place on map
	
	var instance = structureNode.instantiate()
	SceneCounter.structureNodes += 1
	instance.setSpawnerVariables(spawnChanceMod, [gunmanPrefab, thiefPrefab])
	get_node(NodePath("/root/Level/AllTerrain")).add_child(instance)
	instance.position = chunkCoords * tileWidth
	instance.setStructureData(id, structureTypes)
	

#Sets a chunk as empty
func setEmptyChunk(worldCoords : Vector3):
	#coords are in world coordinates
	if(WorldSave.loadedCoords.find(worldCoords) != -1):
		print("Tried to set " + str(worldCoords) + " to empty, but its already loaded!")
		if(WorldSave.retriveData(worldCoords)[0] == ""):
			print("but its already set to empty?")
		return
	WorldSave.addChunk(worldCoords / tileWidth)
	var data = []
	data.append(null)
	WorldSave.saveChunk(worldCoords / tileWidth, data)
	

func printStructureList():
	print("Sructures:")
	for s in structures:
		print("id: " + str(s[0]) + " coords: " + str(s[1]))

func preloadTiles():
	for c in chunkTiles.retrieveChunkTypes():
		load(c)
	for s in tileStructures.retrieveStructureTypes():
		load(s[0])
	for w in chunkTiles.retrieveWallsTypes():
		load(w)
