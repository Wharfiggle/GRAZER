extends Spatial
onready var player = preload("res://Assets/Ball.tscn")

func _ready():
	pass

func _process(delta):
	print("frame")
	if(Input.is_action_just_pressed("debug1")):
		var newPlayer = player.instance()
		newPlayer.transform.origin = (Vector3(0,5,0))
		get_tree().get_root().add_child(newPlayer)
