extends Control


@onready var backButton = $Panel/Back/AudioStreamPlayer2D

var sound = preload("res://sounds/New Sound FEX/UI/extra sounds/Ui_pitch1.wav")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(Input.is_action_just_pressed("dodge")):
		_on_button_pressed()


func _on_button_pressed():
	backButton.stream = sound
	backButton.play()
	await backButton.finished
	get_tree().change_scene_to_file("res://Levels/MainMenuScene.tscn")
