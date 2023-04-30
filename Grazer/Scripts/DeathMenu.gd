#Elijah Southman

extends Panel

func start():
	visible = true
	get_child(1).disabled = false
	get_child(2).disabled = false
	var uiCursor = get_node(NodePath("/root/Level/UICursor"))
	uiCursor.setActive(true)

func _on_restart_button_pressed():
	WorldSave.reset()
	get_tree().change_scene_to_file("res://Levels/Level.tscn")

func _on_main_menu_button_pressed():
	WorldSave.reset()
	get_tree().change_scene_to_file("res://Levels/MainMenuScene.tscn")
