#Elijah Southman

extends Panel

var audioArRay = [
	preload("res://sounds/Cowgirl edited/Character Selection/Character Selection#01.5.wav"),
	preload("res://sounds/Cowgirl edited/Character Selection/Character Selection#01.7.wav"),
	preload("res://sounds/Cowgirl edited/Character Selection/Character Selection#01.9.wav"),
#	preload("res://sounds/Cowgirl edited/Character Selection/Character Selection#01.10.wav"),
	preload("res://sounds/Cowgirl edited/Character Selection/CowGirlVox_GoodPick_.wav")]
var audioArRussel = [
	preload("res://sounds/New Sound FEX/Cowboy/Cowboy_Vox/Cowboy - Bradl#01.7.wav"),
	preload("res://sounds/New Sound FEX/Cowboy/Cowboy_Vox/Cowboy - Bradl#01.19.wav"),
	preload("res://sounds/New Sound FEX/Cowboy/Cowboy_Vox/Cowboy - Bradl#01.62.wav"),
	preload("res://sounds/New Sound FEX/Cowboy/Cowboy_Vox/Cowboy - Bradl#01.65.wav")]
var menuButtionSound = preload("res://sounds/New Sound FEX/UI/Scroll.wav")

@onready var raySound = $CharacterSelect/RayAudio
@onready var russelSound = $CharacterSelect/RusselAudio
@onready var logo = $Logo
@onready var playButton = $playButton/AudioStreamPlayer2D
@onready var creditsButton = $credits/AudioStreamPlayer2D
var rng = RandomNumberGenerator.new()
var selected = false
var tutorial = false

func _ready():
	WorldSave.cows = [0, 0, 0, 0, 0]
	WorldSave.elixirs = [0, 0, 0, 0, 0, 0]
	WorldSave.upgrades = null
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if(WorldSave.fullscreen == null):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	rng.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	if(Input.is_action_just_pressed("dodge")):
#		_on_quit_button_pressed()
#	if(Input.is_action_just_pressed("Interact")):
#		if(logo.visible):
#			_on_button_pressed()
#		else:
#			var joyY = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
#			if(abs(joyY) > 0.3):
#				if(joyY > 0):
#					_on_russel_button_pressed()
#				else:
#					_on_ray_button_pressed()

func _on_button_pressed():
	if(!tutorial):
		WorldSave.cows = [0, 0, 0, 0, 0]
	var charSelect = $CharacterSelect
	charSelect.visible = true
	charSelect.get_child(0).disabled = false
	charSelect.get_child(1).disabled = false
	logo.visible = false
	playButton.stream = menuButtionSound
	playButton.play()
	await playButton.finished

func _on_tutorial_button_pressed():
	tutorial = true
	WorldSave.cows = []
	_on_button_pressed()

func _on_quit_button_pressed():
	get_tree().quit()
	pass # Replace with function body.

func _on_credits_pressed():
	creditsButton.stream = menuButtionSound
	creditsButton.play()
	await creditsButton.finished
	get_tree().change_scene_to_file("res://Levels/credits.tscn")
	
func _on_russel_button_pressed():
	if(selected == false):
		selected = true
		WorldSave.setCharacter(true)
		russelSound.stream = audioArRussel[rng.randi_range(0, audioArRussel.size() - 1)]
		russelSound.play()
		Fade.fade_out(1.0)
		await russelSound.finished
		if(tutorial):
			get_tree().change_scene_to_file("res://Levels/TutorialLevel2.tscn")
		else:
			get_tree().change_scene_to_file("res://Levels/Level.tscn")

func _on_ray_button_pressed():
	if(selected == false):
		selected = true
		WorldSave.setCharacter(false)
		raySound.stream = audioArRay[rng.randi_range(0, audioArRay.size() - 1)]
		raySound.play()
		Fade.fade_out(1.0)
		await raySound.finished
		if(tutorial):
			get_tree().change_scene_to_file("res://Levels/TutorialLevel2.tscn")
		else:
			get_tree().change_scene_to_file("res://Levels/Level.tscn")
