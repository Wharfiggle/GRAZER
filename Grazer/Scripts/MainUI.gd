extends MarginContainer

@onready var healthBar = $HBoxContainer/Bars/bar/TextureProgressBar

@onready var player = get_node("/root/Level/Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	healthBar.max_value=player.maxHitpoints
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
