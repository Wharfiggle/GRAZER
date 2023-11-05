#Elijah Southman

extends Panel

func start(noHealth:bool):
	visible = true
	get_child(2).disabled = false
	get_child(3).disabled = false
	var uiCursor = get_node(NodePath("/root/Level/UICursor"))
	uiCursor.setActive(true)
	if(noHealth):
		get_child(1).visible = false
	else:
		get_child(0).visible = false
	

func _on_restart_button_pressed():
	WorldSave.reset()
	get_tree().change_scene_to_file("res://Levels/Level.tscn")

func _on_main_menu_button_pressed():
	WorldSave.reset()
	get_tree().change_scene_to_file("res://Levels/MainMenuScene.tscn")
