#Elijah Southman

extends Control

#NOTE: 
#For some reason Godot hates this object being a prefab,
#and if you edit it at all it won't work anymore.
#If you edit the prefab and it stops working,
#delete it from Level, then copy paste the root node
#from the ItemWheelUI prefab back into Level.
#It will just arbitrarily work again.

var menuButtonSound = preload("res://sounds/New Sound FEX/UI/Scroll.wav")
var sound = preload("res://sounds/New Sound FEX/UI/extra sounds/Ui_pitch1.wav")
#var hover = preload("res://sounds/New Sound FEX/UI/Scroll.wav")
var menuOpen = preload("res://sounds/New Sound FEX/UI/MenuSlideIn.wav")
var menuClose = preload("res://sounds/New Sound FEX/UI/MenuSlideOutedited.wav")

@onready var controlB = $AudioStreamPlayer2D
@onready var MMB = $MainMenu/AudioStreamPlayer2D

@onready var player = get_node(NodePath("/root/Level/Player"))
@onready var viewport = get_viewport()
@onready var soundMaker = $"item sounds"
@onready var uiCursor = get_node(NodePath("/root/Level/UICursor"))
@onready var controls = $ControlsGraphic

@onready var musicVol = 0
@onready var sfxVol = 0

func togglePause():
	if(!visible):
		soundMaker.stream = menuOpen
		soundMaker.play()
		visible = true
		uiCursor.setActive(true, viewport.get_visible_rect().size / 2)
		get_tree().paused = true
	elif(visible):
		controls.visible = false
		soundMaker.stream = menuClose
		soundMaker.play()
		visible = false
		uiCursor.setActive(false, Vector2(0, 0))
		get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(Input.is_action_just_pressed("Pause") && !player.dead):
		togglePause()
		return
	if(visible):
#		if((Input.is_action_just_pressed("shoot") || Input.is_action_just_pressed("Interact"))):
#			togglePause()
#			return
		if(Input.is_action_just_pressed("dodge")):
			togglePause()

func _on_main_menu_pressed():
	MMB.stream = menuButtonSound
	MMB.play()
	await MMB.finished
	WorldSave.reset()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Levels/MainMenuScene.tscn")

func _on_controls_pressed():
	if(controls.visible==true):
		controlB.stream = menuButtonSound
		controlB.play()
		await controlB.finished
	else :
		controlB.stream = sound
		controlB.play()
		await controlB.finished

	controls.visible = !controls.visible

func _on_toggle_music_pressed():
	soundMaker.stream = menuButtonSound
	soundMaker.play()

func _on_toggle_sfx_pressed():
	soundMaker.stream = menuButtonSound
	soundMaker.play()
