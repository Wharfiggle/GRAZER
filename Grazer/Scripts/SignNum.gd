extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var uses = get_parent().currentUses
	if(uses <= 0 || uses >= 5):
		visible = false
	else:
		visible = true
		text = str(uses) + "/5"
	
