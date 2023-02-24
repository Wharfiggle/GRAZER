extends Spatial

# Declare member variables here.
export (NodePath) var playerNodePath = NodePath("/root/Level/Ball")
export (NodePath) var cowCounterNodePath = NodePath("/root/Level/Cow Counter")
onready var player = get_node(playerNodePath)
onready var cowCounter = get_node(cowCounterNodePath)
var cowPrefab = preload("res://Prefabs/Cow.tscn")
var cows = []
var numCows = 0
var follow = true
var huddle = []
var numHuddle = 0
var canHuddle = true
var followingHerd = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if(player == null):
		print("Herd.gd: error getting player node")
		player = get_node(playerNodePath)
		if(player == null):
			print("Herd.gd: yup still broken")
	if(cowCounter == null):
		print("Herd.gd: error getting counter node")

func _physics_process(_delta):
	if(numHuddle == 0):
		for i in cows:
			i.target = getTarget()
			i.followingHerd = followingHerd
	else:
		for i in huddle:
			i.target = Vector2(player.translation.x, player.translation.z)
			i.followingHerd = false

func toggleFollow():
	follow = !follow
	for i in cows:
		i.follow = follow

func getCow(index) -> Node:
	return cows[index]
	
func getCows() -> Array:
	return cows

func addCow(cow):
	cows.append(cow)
	numCows += 1
	add_child(cow)
	cow.follow = follow
	cow.target = getTarget()
	cow.followingHerd = followingHerd
	cow.herd = self

func removeCow(cow):
	cows.erase(cow)
	numCows -= 1
	remove_child(cow)
	get_node(NodePath("/root/Level")).add_child(cow)
	cow.follow = false
	cow.target = null
	cow.followingHerd = false

func spawnCow() -> Node:
	var cow = cowPrefab.instance()
	cow.translation = Vector3(0, 10, 0)
	addCow(cow)
	cowCounter.updateCowNum(numCows)
	return cow

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
		
func addHuddler(huddler):
	huddle.append(huddler)
	numHuddle += 1
	huddler.target = Vector2(player.translation.x, player.translation.z)
	huddler.followingHerd = false
	var target = getTarget()
	for i in cows:
		if(i.huddling == false):
			i.target = target
			i.followingHerd = followingHerd
			
func removeHuddler(huddler):
	huddle.erase(huddler)
	numHuddle -= 1
	huddler.target = getTarget()
	huddler.followingHerd = followingHerd
	
func clearHuddle():
	numHuddle = 0
	for i in huddle:
		i.huddling = false
		i.target = getTarget()
		i.followingHerd = followingHerd
	huddle.clear()

func findHerdCenter() -> Vector3:
	var loc = Vector3(0,0,0)
	if(numCows > 0):
		for i in cows:
			loc += i.transform.origin
		loc /= numCows
	else:
		loc = Vector3(0, 10, 0)
	return loc
