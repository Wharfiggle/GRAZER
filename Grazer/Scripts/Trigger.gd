extends Area3D

@onready var collider = get_node(NodePath("./CollisionShape3D"))
var spawners
@export var timeDelay:float
var timer = -1.0
var spawnerInd = 0
var chanceMod = 0
#Elijah Southman

var prefabs = []

# Called when the node enters the scene tree for the first time.
func _ready():
	spawners = get_children()
	
	var debugMesh = get_child(0)
	if(collider == null):
		collider = get_child(1)
	
	var eraseFromSpawners = []
	for i in spawners.size():
		if(!spawners[i].has_method("spawn")):
			if(spawners[i] != debugMesh && spawners[i] != collider):
				print("Trigger contained invalid object: " + str(spawners[i]) + ". Removing...")
			eraseFromSpawners.append(spawners[i])
	for i in eraseFromSpawners.size():
		spawners.erase(eraseFromSpawners[i])
	
	debugMesh.queue_free()
	collider.disabled = true

func _physics_process(delta):
	if(timer > -1):
		timer -= delta
		if(timer <= 0):
			if(spawners[spawnerInd].has_method("spawn")):
				spawners[spawnerInd].spawn(chanceMod, prefabs)
			spawnerInd += 1
			if(spawnerInd < spawners.size() - 1):
				timer = timeDelay
			else:
				timer = -2
	if(spawnerInd >= spawners.size()):
		var allNull = true
		for i in spawners.size():
			if(spawners[i] != null):
				allNull = false
		if(allNull):
			queue_free()

func _on_body_entered(body):
	if(body.is_in_group('Player') && timer == -1):
		timer = timeDelay
		print("triggered: " + str(prefabs))
	collider.disabled = true
	
func spawn(inChanceMod:float, inPrefabs):
	collider.disabled = false
	chanceMod = inChanceMod
	prefabs = inPrefabs
