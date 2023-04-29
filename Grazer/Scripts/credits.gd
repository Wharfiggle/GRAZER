extends Control


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(Input.is_action_just_pressed("dodge")):
		_on_button_pressed()


func _on_button_pressed():
	get_tree().change_scene_to_file("res://Levels/MainMenuScene.tscn")
