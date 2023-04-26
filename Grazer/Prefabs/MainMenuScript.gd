extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(Input.is_action_just_pressed("dodge")):
		_on_quit_button_pressed()
	if(Input.is_action_just_pressed("Interact")):
		_on_button_pressed()


func _on_button_pressed():
	var charSelect = $CharacterSelect
	charSelect.visible = true
	charSelect.get_child(0).get_child(0).disabled = false
	charSelect.get_child(0).get_child(1).disabled = false
	
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
