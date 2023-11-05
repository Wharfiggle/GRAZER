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
var fullscreen = false

@onready var controlB = $AudioStreamPlayer2D
@onready var MMB = $PauseBackground/MainMenu/AudioStreamPlayer2D

@onready var player = get_node(NodePath("/root/Level/Player"))
@onready var viewport = get_viewport()
@onready var soundMaker = $"item sounds"
@onready var uiCursor = get_node(NodePath("/root/Level/UICursor"))
@onready var controls = $ControlsGraphic
@onready var pauseBackground = $PauseBackground

@onready var musicVol = 0
@onready var sfxVol = 0
@onready var fullscreenButton = $PauseBackground/Fullscreen
@onready var musicButton = $PauseBackground/Music
@onready var sfxButton = $PauseBackground/SFX

var toggleTrue = preload("res://Assets/Images/NewUI/Asset_6.png")
var toggleFalse = preload("res://Assets/Images/NewUI/Asset_7.png")

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

func _ready():
	if(WorldSave.fullscreen == null):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullscreen = true
		fullscreenButton.texture_normal = toggleTrue
	else:
		fullscreen = WorldSave.fullscreen
		fullscreenButton.texture_normal = toggleFalse

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
	pauseBackground.visible = !controls.visible

func _on_music_pressed():
	var level = get_node(NodePath("/root/Level"))
	var buses = []
	buses.append(AudioServer.get_bus_index("Music"))
	var mute = not AudioServer.is_bus_mute(buses[0])
	for i in buses:
		AudioServer.set_bus_mute(i, mute)
	level.muteMusic(mute)
	soundMaker.stream = menuButtonSound
	soundMaker.play()
	if(mute):
		musicButton.texture_normal = toggleFalse
	else:
		musicButton.texture_normal = toggleTrue

func _on_sfx_pressed():
	var buses = []
	buses.append(AudioServer.get_bus_index("SoundFXMain"))
	buses.append(AudioServer.get_bus_index("GunShots"))
	buses.append(AudioServer.get_bus_index("Ambience"))
	buses.append(AudioServer.get_bus_index("Voices"))
	buses.append(AudioServer.get_bus_index("EnemyVoice"))
	var mute = not AudioServer.is_bus_mute(buses[0])
	for i in buses:
		AudioServer.set_bus_mute(i, mute)
	soundMaker.stream = menuButtonSound
	soundMaker.play()
	if(mute):
		sfxButton.texture_normal = toggleFalse
	else:
		sfxButton.texture_normal = toggleTrue

func _on_fullscreen_pressed():
	fullscreen = !fullscreen
	if(fullscreen):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		WorldSave.fullscreen = true
		fullscreenButton.texture_normal = toggleTrue
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		WorldSave.fullscreen = false
		fullscreenButton.texture_normal = toggleFalse

func _on_resume_pressed():
	togglePause()
