extends Area3D
var triggered = false
@onready var winScreen = get_node(NodePath("/root/Level/WinMenu"))

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_body_entered(body):
	if(body.is_in_group('Player') and !triggered):
		print("Player win")
		triggered = true
		await Fade.fade_out(2).finished
		winScreen.start()
		Fade.fade_in()
