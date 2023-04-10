extends Node3D
@export var paths = []
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	get_child(0).queue_free()

func spawn():
	rng.randomize()
	var rn = rng.randi_range(0, paths.size() - 1)
	var instance = load(paths[rn]).instantiate()
	if(instance != null):
		get_node("/root/Level").add_child(instance)
		instance.global_position = global_position
	else:
		print("invalid path in decoration spawner: " + str(paths[rn]))
	self.queue_free()
