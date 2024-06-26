#Elijah Southman

extends Node3D

# Declare member variables here.
@onready var player = get_node(NodePath("/root/Level/Player"))
@onready var cowCounter = get_node(NodePath("/root/Level/Cow Counter"))
var cowPrefab = preload("res://Prefabs/NewCow.tscn")
var checkpointMarkerPrefab = preload("res://Prefabs/CheckpointMarker.tscn")
var cows = []
#number of total cows
var numCows = 0
#cows follow player if true or wait if false
var follow = true
#cows in huddle around player
var huddle = []
#number of cows in huddle
var numHuddle = 0
#are cows allowed to huddle? only true when player is not moving
var canHuddle = true
#true if the cows are following the center of the huddle, false if following the player
var followingHerd = false
#how many meters behind the player the target should be
var playerTargetOffset = 3.0

var potionSpeedup = 1.0

var dragResistance = 1.0

var cowsBeingStolen = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if(player == null):
		print("Herd.gd: error getting player node")
	if(cowCounter == null):
		print("Herd.gd: error getting cow counter node")

func _physics_process(_delta):
	if(numHuddle == 0): #set all cows target to player since there is no huddle
		for i in cows:
			i.target = getTarget()
			i.followingHerd = followingHerd
	else: #set cows target in huddle to player so they look at him
		for i in huddle:
			i.target = getPlayerTarget()
			i.followingHerd = false

#toggle follow/wait
func toggleFollow():
	follow = !follow
	for i in cows:
		i.follow = follow
		if(follow):
			i.speedBoostTimer = 1.0

#get cow from cows[] array
func getCow(index) -> Node:
	return cows[index]

#get cows[] array
func getCows() -> Array:
	return cows

#get total number of cows
func getNumCows() -> int:
	return numCows

#returns the cow closest to the given position
func getClosestCow(loc) -> Node:
	var closestCow = null
	var distance = 1000000
	for c in cows:
		if(c.position.distance_to(loc) < distance and c.getNumDraggers() == 0):
			closestCow = c
			distance = c.position.distance_to(loc)
	return closestCow

func setPotionSpeedup(inPotionSpeedup):
	if(inPotionSpeedup != potionSpeedup):
		potionSpeedup = inPotionSpeedup
		for i in cows:
			i.potionSpeedup = potionSpeedup
			
func setDragResistance(inDragResistance):
	if(inDragResistance != dragResistance):
		dragResistance = inDragResistance
		for i in cows:
			i.dragResistance = dragResistance
			if(!i.draggers.is_empty()):
				i.maxSpeed = min(i.dragSpeed * i.draggers.size() / dragResistance, i.draggers[0].baseSpeed)

#add cow to player's herd
func addCow(cow, playSound:bool = true):
	if(playSound):
		cow.makeMoo()
	cows.append(cow)
	numCows += 1
	cowCounter.updateCowNum(numCows)
	if(cow.get_parent() != self):
		add_child(cow)
	#cow.follow = follow
	cow.target = getTarget()
	cow.followingHerd = followingHerd
	cow.dragResistance = dragResistance
	cow.potionSpeedup = potionSpeedup
	cow.herd = self
	player.cowTypes[cow.cowTypeInd].use()
	clearHuddle()

#remove cow from player's herd
func removeCow(cow):
	if(cows.has(cow)):
		cows.erase(cow)
		huddle.erase(cow)
		numCows -= 1
		cowCounter.updateCowNum(numCows)
		remove_child(cow)
		get_node(NodePath("/root/Level")).add_child(cow)
		cow.idle()
		player.cowTypes[cow.cowTypeInd].use(false)

func deleteCow(cow):
	#removeCow(cow)
	cow.delete()

#spawn a cow in center of herd
func spawnCow(type:int = -1) -> Node:
	var cow = spawnCowAtPos(findHerdCenter(), type)
	return cow
#spawn cow at given position
func spawnCowAtPos(pos:Vector3, type:int = -1) -> Node:
	var cow = cowPrefab.instantiate()
	cow.setType(type)
	add_child(cow)
	cow.position = pos
	addCow(cow, false)
	return cow
#spawn stray cow
func spawnStrayCow(pos:Vector3, type:int = -1) -> Node:
	var cow = cowPrefab.instantiate()
	cow.setType(type)
	add_child(cow)
	cow.position = pos
	cow.stray = true
	cow.add_to_group('DespawnAtCheckpoint')
	return cow

func spawnCheckpointMarker(pos:Vector3) -> Node:
	var cow = checkpointMarkerPrefab.instantiate()
	cow.checkpointMarker = true
	cow.setType(0)
	add_child(cow)
	cow.position = pos
	cow.stray = true
	cow.add_to_group('DespawnAtCheckpoint')
	return cow

#get target for cows to follow, either player's position or center of huddle
func getTarget() -> Vector2:
	if(numHuddle == 0):
		followingHerd = false
		return getPlayerTarget()
	else:
		var loc = getPlayerTarget()
		for i in huddle:
			loc += Vector2(i.position.x, i.position.z)
		loc /= numHuddle + 1
		followingHerd = true
		return loc
func getPlayerTarget() -> Vector2:
	return Vector2(
		player.position.x - sin(player.rotation.y) * playerTargetOffset, 
		player.position.z - cos(player.rotation.y) * playerTargetOffset)

#add cow to huddle
func addHuddler(huddler):
	huddle.append(huddler)
	numHuddle += 1
	huddler.target = getPlayerTarget()
	huddler.followingHerd = false
	huddler.huddling = true
	huddler.disableRayCasts()
	var target = getTarget()
	for i in cows:
		if(i != null && i.huddling == false):
			i.target = target
			i.followingHerd = followingHerd

#remove cow from huddle
func removeHuddler(huddler):
	if(huddle.has(huddler)):
		huddle.erase(huddler)
		numHuddle -= 1
		huddler.target = getTarget()
		huddler.followingHerd = followingHerd
		huddler.huddling = false
		huddler.enableRayCasts()

#remove all cows from huddle
func clearHuddle():
	numHuddle = 0
	for i in huddle:
		i.huddling = false
		i.target = getTarget()
		i.followingHerd = followingHerd
		i.enableRayCasts()
	huddle.clear()

#find center of all cows
func findHerdCenter() -> Vector3:
	var loc = Vector3(0,0,0)
	var num = 0
	for i in cows:
		if(i.draggers.is_empty()):
			loc += i.transform.origin
			num += 1
	if(num > 0):
		loc /= num
	else:
		loc = player.position
	return loc
