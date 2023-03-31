extends Node3D
@onready var player = get_node("/root/Level/Player")

var pathname = ""
var width = 1
var depth = 1
var renderRange = 3
var scene
var loading = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var distance = player.position.distance_to(position)
	if(ResourceLoader.load_threaded_get_status(pathname) == 3):
		#This function will freeze the game until the scene is fully loaded
		#But once loaded, it does return the reference to the scene that we need
		var chunk = ResourceLoader.load_threaded_get(pathname)
		await get_tree().process_frame
		var instance = chunk.instantiate()
		add_child(instance)
		scene = instance
		loading = false
	
	if(distance <= renderRange and scene == null):
		ResourceLoader.load_threaded_request(pathname,"",false, ResourceLoader.CACHE_MODE_REUSE)
		
	elif(distance > renderRange + 1 and scene != null):
		scene.queue_free()
		
