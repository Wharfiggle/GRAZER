#Elijah Southman

extends Control

#NOTE: 
#For some reason Godot hates this object being a prefab,
#and if you edit it at all it won't work anymore.
#If you edit the prefab and it stops working,
#delete it from Level, then copy paste the root node
#from the ItemWheelUI prefab back into Level.
#It will just arbitrarily work again.

@onready var player = get_node(NodePath("/root/Level/Player"))
@onready var cells = [
	$Cell1,
	$Cell2,
	$Cell3,
	$Cell4,
	$Cell5,
	$Cell6
]
var highlight = [0, 0, 0, 0, 0, 0]
var selected = 0
@onready var origTransparency = cells[0].modulate.a
@onready var origScale = cells[0].scale.x
var wheelRadius = 200
@onready var viewport = get_viewport()
@onready var elixirName = $ElixirName
@onready var elixirDesc = $ElixirDesc
@onready var soundMaker = $"item sounds"
var hover = preload("res://sounds/New Sound FEX/UI/Scroll.wav")
var menuOpen = preload("res://sounds/New Sound FEX/UI/MenuSlideIn.wav")
var menuClose = preload("res://sounds/New Sound FEX/UI/MenuSlideOutedited.wav")
@onready var uiCursor = get_node(NodePath("/root/Level/UICursor"))
@onready var controls = $ControlsGraphic

func toggleItemWheel():
	if(!visible):
		for i in cells.size():
			var itemNum = player.inventory[i]
			cells[i].get_child(2).text = str(itemNum)
			var elixirIcon = cells[i].get_child(0)
			if(itemNum > 0):
				elixirIcon.visible = true
			else:
				elixirIcon.visible = false
				
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
		uiCursor.setActive(false)
		highlight = [0, 0, 0, 0, 0, 0]
		for i in cells.size():
			cells[i].modulate.a = origTransparency
			cells[i].scale = Vector2(origScale, origScale)
		get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(Input.is_action_just_pressed("ItemWheel") && player.active):
		toggleItemWheel()
	if(visible):
		if((Input.is_action_just_pressed("shoot") || Input.is_action_just_pressed("Interact")) 
		&& selected != -1 && player.inventory[selected] > 0):
			player.usePotion(selected)
			toggleItemWheel()
		if(Input.is_action_just_pressed("dodge")):
			toggleItemWheel()
		
#		var stickVec = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
#		if(stickVec.length() > 0.3):
#			var selectAngle = atan2(stickVec.x, stickVec.y)
#			selectAngle = fmod(selectAngle + PI - PI / 6.0, PI * 2)
#			selectAngle = 2 * PI - selectAngle
#			selectAngle = fmod(selectAngle, PI * 2)
#			selected = selectAngle / (PI / 3.0) as int
#		else:
		var mousePos = viewport.get_mouse_position()
		mousePos -= viewport.get_visible_rect().size / 2
		if(mousePos.length() > wheelRadius):
			selected = -1
		
		if(selected != -1):
			elixirName.text = player.potions[selected].name
			elixirDesc.text = player.potions[selected].description
		
		for i in highlight.size():
			var target = 1.0
			if(selected != i):
				target = 0.0
			highlight[i] = lerpf(highlight[i], target, 0.1)
			cells[i].modulate.a = origTransparency + (1 - origTransparency) * highlight[i]
			var newScale = origScale + (1 - origScale) * highlight[i]
			cells[i].scale = Vector2(newScale, newScale)

func _on_cell_1_mouse_entered():
	soundMaker.stream = hover
	soundMaker.play()
	#put sound here
	selected = 0
func _on_cell_2_mouse_entered():
	soundMaker.stream = hover
	soundMaker.play()
	selected = 1
func _on_cell_3_mouse_entered():
	soundMaker.stream = hover
	soundMaker.play()
	selected = 2
func _on_cell_4_mouse_entered():
	soundMaker.stream = hover
	soundMaker.play()
	selected = 3
func _on_cell_5_mouse_entered():
	soundMaker.stream = hover
	soundMaker.play()
	selected = 4
func _on_cell_6_mouse_entered():
	soundMaker.stream = hover
	soundMaker.play()
	selected = 5

func _on_main_menu_pressed():
	WorldSave.reset()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Levels/MainMenuScene.tscn")

func _on_controls_pressed():
	controls.visible = !controls.visible
