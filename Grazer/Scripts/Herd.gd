#Elijah Southman

extends Spatial

# Declare member variables here.
export (NodePath) var playerNodePath = NodePath("/root/Level/Ball")
export (NodePath) var cowCounterNodePath = NodePath("/root/Level/Cow Counter")
onready var player = get_node(playerNodePath)
onready var cowCounter = get_node(cowCounterNodePath)
var cowPrefab = preload("res://Prefabs/Cow.tscn")
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
			i.target = Vector2(player.translation.x, player.translation.z)
			i.followingHerd = false

#toggle follow/wait
func toggleFollow():
	follow = !follow
	for i in cows:
		i.follow = follow

#get cow from cows[] array
func getCow(index) -> Node:
	return cows[index]

#get cows[] array
func getCows() -> Array:
	return cows

#get total number of cows
func getNumCows() -> int:
	return numCows

#add cow to player's herd
func addCow(cow):
	cows.append(cow)
	numCows += 1
	add_child(cow)
	cow.follow = follow
	cow.target = getTarget()
	cow.followingHerd = followingHerd
	cow.herd = self

#remove cow from player's herd
func removeCow(cow):
	cows.erase(cow)
	numCows -= 1
	remove_child(cow)
	get_node(NodePath("/root/Level")).add_child(cow)
	cow.follow = false
	cow.target = null
	cow.followingHerd = false

#spawn a cow in center of world
func spawnCow() -> Node:
	var cow = cowPrefab.instance()
	cow.translation = Vector3(0, 10, 0)
	addCow(cow)
	cowCounter.updateCowNum(numCows)
	return cow

#get target for cows to follow, either player's position or center of huddle
func getTarget() -> Vector2:
	if(numHuddle == 0):
		followingHerd = false
		return Vector2(player.translation.x, player.translation.z)
	else:
		var loc = Vector2(player.translation.x, player.translation.z)
		for i in huddle:
			loc += Vector2(i.translation.x, i.translation.z)
		loc /= numHuddle + 1
		followingHerd = true
		return loc

#add cow to huddle
func addHuddler(huddler):
	huddle.append(huddler)
	numHuddle += 1
	huddler.target = Vector2(player.translation.x, player.translation.z)
	huddler.followingHerd = false
	huddler.huddling = true
	huddler.disableRayCasts()
	var target = getTarget()
	for i in cows:
		if(i.huddling == false):
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
	if(numCows > 0):
		for i in cows:
			loc += i.transform.origin
		loc /= numCows
	else:
		loc = Vector3(0, 10, 0)
	return loc
