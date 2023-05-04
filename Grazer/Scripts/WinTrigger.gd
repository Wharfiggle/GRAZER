extends Area3D
var triggered = false
@onready var winScreen = get_node(NodePath("/root/Level/WinMenu"))

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	pass

func _on_body_entered(body):
	if(body.is_in_group('Player') and !triggered):
		print("Player win")
		get_node(NodePath("/root/Level")).changeMusic(5, 3.0)
		triggered = true
		body.potionSpeedup = 0.5
		await Fade.fade_out(3).finished
		winScreen.start()
		Fade.fade_in()
		winScreen.pan()
