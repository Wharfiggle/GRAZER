#Elijah Southman

extends Panel

var audioArRay = [
	preload("res://sounds/Cowgirl edited/Character Selection/Character Selection#01.5.wav"),
	preload("res://sounds/Cowgirl edited/Character Selection/Character Selection#01.7.wav"),
	preload("res://sounds/Cowgirl edited/Character Selection/Character Selection#01.9.wav"),
	preload("res://sounds/Cowgirl edited/Character Selection/Character Selection#01.10.wav"),
	preload("res://sounds/Cowgirl edited/Character Selection/CowGirlVox_GoodPick_.wav")]
var audioArRussel = [
	preload("res://sounds/New Sound FEX/Cowboy/Cowboy_Vox/Cowboy - Bradl#01.7.wav"),
	preload("res://sounds/New Sound FEX/Cowboy/Cowboy_Vox/Cowboy - Bradl#01.19.wav"),
	preload("res://sounds/New Sound FEX/Cowboy/Cowboy_Vox/Cowboy - Bradl#01.62.wav"),
	preload("res://sounds/New Sound FEX/Cowboy/Cowboy_Vox/Cowboy - Bradl#01.65.wav")]
var music = preload("res://sounds/Copy of Opening Theme Demo 1.WAV")
@onready var musicPlayer = $AudioStreamPlayer2D
#@onready var raySound = $CharacterSelect/RayAudio
@onready var SelectSound = $CharacterSelect/selectAudio
var rng = RandomNumberGenerator.new()
var selected = false
@onready var RayButton = $CharacterSelect/rayButton
@onready var RussleButton = $CharacterSelect/russelButton

func _ready():
	rng.randomize()
	musicPlayer.set_stream(music)
	musicPlayer.play(4.61)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(Input.is_action_just_pressed("dodge")):
		_on_quit_button_pressed()
	if(Input.is_action_just_pressed("Interact")):
		_on_button_pressed()
		
		
	
	#if (RayButton.is_hovered()):
	#	SelectSound.stream =audioArRay[randi_range(0, audioArRay.size() - 1)]
	#	SelectSound.play()
	
	#elif (RayButton):
	#	SelectSound.stream =audioArRussel[randi_range(0, audioArRussel.size() - 1)]
	#	SelectSound.play()
	
	
	

func _on_button_pressed():
	var charSelect = $CharacterSelect
	charSelect.visible = true
	charSelect.get_child(0).disabled = false
	charSelect.get_child(1).disabled = false
	
func _on_quit_button_pressed():
	
	get_tree().quit()
	pass # Replace with function body.

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://Levels/credits.tscn")

func _on_russel_button_pressed():
	if(selected == false):
		selected = true
		WorldSave.setCharacter(true)
		SelectSound.stream = audioArRussel[rng.randi_range(0, audioArRussel.size() - 1)]
		SelectSound.play()
		await SelectSound.finished
		get_tree().change_scene_to_file("res://Levels/Level.tscn")

func _on_ray_button_pressed():
	if(selected == false):
		selected = true
		WorldSave.setCharacter(false)
		SelectSound.stream = audioArRay[rng.randi_range(0, audioArRay.size() - 1)]
		SelectSound.play()
		await SelectSound.finished
		get_tree().change_scene_to_file("res://Levels/Level.tscn")
	


