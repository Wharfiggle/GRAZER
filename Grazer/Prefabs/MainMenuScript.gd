extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	#only use if we chose to do scene change
	get_tree().change_scene_to_file("res://Levels/Level.tscn")
	

func _on_quit_button_pressed():
	
	get_tree().quit()
	pass # Replace with function body.


func _on_credits_pressed():
	get_tree().change_scene_to_file("res://Prefabs/credits.tscn")
