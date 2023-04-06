extends Node3D
@export var objectStringToSpawn = ""
@export var path = ""
var instance

# Called when the node enters the scene tree for the first time.
func _ready():
	#Return if a path has already been chosen
	if(path != ""): 
		return
	match[]:
		["gunman"]:
			path = "res://Prefabs/Gunman.tscn"
		["thief"]:
			path = "res://Prefabs/Thief.tscn"
		#TODO Add more options like items


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawn():
	if(path != ""):
		instance = load(path).instantiate()
		instance.set_parent(get_node("/root/Level"))
		instance.position = position
		self.queue_free()
