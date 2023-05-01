#Modified from Elijah's DeathMenu.gd
extends Panel

var panDistance = 440.0
var panSpeed = 25.0
var curPan = 0
var panning = false
var startingPosition
@onready var endScreen = $EndScreen

func _ready():
	startingPosition = position
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	if(panning and curPan < panDistance):
		var p = Vector2(endScreen.position.x - panSpeed * delta, endScreen.position.y)
		endScreen.set_position(p)
		curPan += panSpeed * delta
	elif(panning):
		panning = false

func start():
	visible = true
	get_child(2).disabled = false
	get_child(3).disabled = false
	var uiCursor = get_node(NodePath("/root/Level/UICursor"))
	uiCursor.setActive(true)
	get_tree().paused = true
	get_node(NodePath("/root/Level")).changeMusic(5)

func pan():
	panning = true

func _on_restart_button_pressed():
	WorldSave.reset()
	get_tree().change_scene_to_file("res://Levels/Level.tscn")
	get_tree().paused = false


func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://Levels/MainMenuScene.tscn")
	get_tree().paused = false
