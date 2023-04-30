#Modified from Elijah's DeathMenu.gd
extends Panel

func start():
	visible = true
	get_child(2).disabled = false
	get_child(3).disabled = false
	var uiCursor = get_node(NodePath("/root/Level/UICursor"))
	uiCursor.setActive(true)
	get_tree().paused = true
	get_node(NodePath("/root/Level")).changeMusic(5)

func _on_restart_button_pressed():
	WorldSave.reset()
	get_tree().change_scene_to_file("res://Levels/Level.tscn")
	get_tree().paused = false

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://Levels/MainMenuScene.tscn")
	get_tree().paused = false
