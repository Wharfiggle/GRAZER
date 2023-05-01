extends Area3D

var parent
@onready var interactGraphic = get_child(0)
var inRange = false
var active = true
@onready var player = get_node(NodePath("/root/Level/Player"))

# Called when the node enters the scene tree for the first time.
func _ready():
	parent = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(Input.is_action_just_pressed("Interact") && parent.has_method("use") && inRange
#	&& player.hitpoints > 0 && player.herd.getNumCows() > 0):
	&& player.active):
		parent.use()
	
	var targAlpha = 0
	if(!inRange || !active):
		targAlpha = 1.0
	interactGraphic.transparency = lerpf(interactGraphic.transparency, targAlpha, 0.2)
	
func _on_body_entered(body):
	if(body.is_in_group('Player')):
		inRange = true

func _on_body_exited(body):
	if(body.is_in_group('Player')):
		inRange = false
