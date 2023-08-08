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

#@onready var controlB=$AudioStreamPlayer2D
#@onready var MMB = $MainMenu/AudioStreamPlayer2D

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
#@onready var controls = $ControlsGraphic
var prevMouse = Vector2(0, 0)
@onready var worldCursor = get_node(NodePath("../Player/WorldCursor"))

func toggleItemWheel():
	if(!visible):
		worldCursor = get_node(NodePath("../Player/WorldCursor"))
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
		if(worldCursor.visible):
			uiCursor.setActive(true, viewport.get_visible_rect().size / 2)
			prevMouse = Vector2(0, 0)
		else:
			prevMouse = viewport.get_mouse_position()
		get_tree().paused = true
	elif(visible):
		worldCursor.get_parent().mousePos = viewport.get_mouse_position()
#		controls.visible = false
		soundMaker.stream = menuClose
		soundMaker.play()
		visible = false
		uiCursor.setActive(false, Vector2(0, 0))
		#worldCursor.visible = false
		highlight = [0, 0, 0, 0, 0, 0]
		for i in cells.size():
			cells[i].modulate.a = origTransparency
			cells[i].scale = Vector2(origScale, origScale)
		get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#toggle item wheel whenever the player is alive and when the shop menus and pause menus are closed
	if(Input.is_action_just_pressed("ItemWheel") && player.active):
#		var egm = get_node(NodePath("/root/Level/ElixirGunMenu"))
#		var hm = get_node(NodePath("/root/Level/HerdMenu"))
		var pm = $"../PauseMenuUI"
#		if((egm == null || !egm.active) || !Input.is_action_just_pressed("SwapMenu")):
#		if((egm == null || egm.active == false) && (hm == null || hm.active == false) && (pm == null || pm.visible == false)):
		if(pm == null || pm.visible == false):
			toggleItemWheel()
			return
	if(visible):
		if((Input.is_action_just_pressed("shoot") || Input.is_action_just_pressed("Interact"))
		&& selected != -1 && player.inventory[selected] > 0):
			player.usePotion(selected)
			toggleItemWheel()
			return
		if(Input.is_action_just_pressed("dodge")):
			toggleItemWheel()
			return
		if(Input.is_action_just_pressed("Pause")):
			visible = false
			highlight = [0, 0, 0, 0, 0, 0]
			for i in cells.size():
				cells[i].modulate.a = origTransparency
				cells[i].scale = Vector2(origScale, origScale)
		
		var stickVec = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
		var rightStick = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
		if(abs(rightStick) > abs(stickVec)):
			stickVec = rightStick
		if(stickVec.length() > 0.3):
			var selectAngle = atan2(stickVec.x, stickVec.y)
			selectAngle = fmod(selectAngle + PI - PI / 6.0, PI * 2)
			selectAngle = 2 * PI - selectAngle
			selectAngle = fmod(selectAngle, PI * 2)
			var prevSelected = selected
			selected = selectAngle / (PI / 3.0) as int
			if(selected != prevSelected):
				soundMaker.stream = hover
				soundMaker.play()
#				match(selected):
#					0: _on_cell_1_mouse_entered()
#					1: _on_cell_2_mouse_entered()
#					2: _on_cell_3_mouse_entered()
#					3: _on_cell_4_mouse_entered()
#					4: _on_cell_5_mouse_entered()
#					5: _on_cell_6_mouse_entered()
			if(uiCursor.active):
				uiCursor.setActive(false, Vector2(0, 0))
				worldCursor.visible = false
				prevMouse = viewport.get_mouse_position()
		else:
			var mousePos = viewport.get_mouse_position()
			if(!uiCursor.active && prevMouse != mousePos):
				uiCursor.setActive(true, viewport.get_visible_rect().size / 2)
				mousePos = global_position
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
	hoverSetSelected(0)
func _on_cell_2_mouse_entered():
	hoverSetSelected(1)
func _on_cell_3_mouse_entered():
	hoverSetSelected(2)
func _on_cell_4_mouse_entered():
	hoverSetSelected(3)
func _on_cell_5_mouse_entered():
	hoverSetSelected(4)
func _on_cell_6_mouse_entered():
	hoverSetSelected(5)
	
func hoverSetSelected(ind):
	if(selected != ind):
		soundMaker.stream = hover
		soundMaker.play()
	selected = ind

#func _on_main_menu_pressed():
#	MMB.stream = menuButtonSound
#	MMB.play()
#	await MMB.finished
#	WorldSave.reset()
#	get_tree().paused = false
#	get_tree().change_scene_to_file("res://Levels/MainMenuScene.tscn")
#
#func _on_controls_pressed():
#	if(controls.visible==true):
#		controlB.stream = menuButtonSound
#		controlB.play()
#		await controlB.finished
#	else :
#		controlB.stream = sound
#		controlB.play()
#		await controlB.finished
#
#	controls.visible = !controls.visible
	
	
