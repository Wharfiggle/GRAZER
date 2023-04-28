extends Panel


var Rayvoice1 = preload("res://sounds/Cowgirl edited/Character Selection/Character Selection#01.5.wav")
var Rayvoice2 = preload("res://sounds/Cowgirl edited/Character Selection/Character Selection#01.7.wav")
var Rayvoice3 = preload("res://sounds/Cowgirl edited/Character Selection/Character Selection#01.9.wav")
var Rayvoice4 = preload("res://sounds/Cowgirl edited/Character Selection/Character Selection#01.10.wav")
var Rayvoice5 = preload("res://sounds/Cowgirl edited/Character Selection/CowGirlVox_GoodPick_.wav")

var audioArrayRay = [Rayvoice1,Rayvoice2,Rayvoice3,Rayvoice4,Rayvoice5]

var Russelvoice1 = preload("res://sounds/New Sound FEX/Cowboy/Cowboy_Vox/Cowboy - Bradl#01.7.wav")
var Russelvoice2 = preload("res://sounds/New Sound FEX/Cowboy/Cowboy_Vox/Cowboy - Bradl#01.19.wav")
var Russelvoice3 = preload("res://sounds/New Sound FEX/Cowboy/Cowboy_Vox/Cowboy - Bradl#01.62.wav")
var Russelvoice4 = preload("res://sounds/New Sound FEX/Cowboy/Cowboy_Vox/Cowboy - Bradl#01.65.wav")

var audioArrayRussel = [Russelvoice1,Russelvoice2,Russelvoice3,Russelvoice4]


# Called when the node enters the scene tree for the first time.
#func _ready():
#	var rayselection = $CharacterSelect/HBoxContainer/rayButton/AudioStreamPlayer2Drayselection
#	var russelselection =  $CharacterSelect/HBoxContainer/russelButton/AudioStreamPlayer2D# Replace with function body.
#	var russleButton = $CharacterSelect/HBoxContainer/russelButton
#	var rayButton = $CharacterSelect/HBoxContainer/rayButton
	
	#var clip_to_play = audioArrayRay[randi() % audioArrayRay.size()] 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(Input.is_action_just_pressed("dodge")):
		_on_quit_button_pressed()
	if(Input.is_action_just_pressed("Interact")):
		_on_button_pressed()
	
	
	


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
	WorldSave.setCharacter(true)
	get_tree().change_scene_to_file("res://Levels/Level.tscn")

func _on_ray_button_pressed():
	WorldSave.setCharacter(false)
	get_tree().change_scene_to_file("res://Levels/Level.tscn")
	


