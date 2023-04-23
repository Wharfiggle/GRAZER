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
var selected = -1
@onready var origTransparency = cells[0].modulate.a
@onready var origScale = cells[0].scale.x
var wheelRadius = 200
@onready var viewport = get_viewport()

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
				
		visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		viewport.warp_mouse(viewport.get_visible_rect().size / 2)
		get_tree().paused = true
	elif(visible):
		visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		highlight = [0, 0, 0, 0, 0, 0]
		selected = -1
		for i in cells.size():
			cells[i].modulate.a = origTransparency
			cells[i].scale = Vector2(origScale, origScale)
		get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(Input.is_action_just_pressed("ItemWheel") && player.active):
		toggleItemWheel()
	if((Input.is_action_just_pressed("shoot") || Input.is_action_just_pressed("reload")) 
	&& selected != -1 && player.inventory[selected] > 0):
		player.usePotion(selected)
		toggleItemWheel()
	if(visible):
		for i in highlight.size():
			var target = 1.0
			if(selected != i):
				target = 0.0
			highlight[i] = lerpf(highlight[i], target, 0.1)
			cells[i].modulate.a = origTransparency + (1 - origTransparency) * highlight[i]
			var newScale = origScale + (1 - origScale) * highlight[i]
			cells[i].scale = Vector2(newScale, newScale)
			
		var mousePos = viewport.get_mouse_position()
		mousePos -= viewport.get_visible_rect().size / 2
		if(mousePos.length() > wheelRadius):
			selected = -1

func _on_cell_1_mouse_entered():
	selected = 0
func _on_cell_2_mouse_entered():
	selected = 1
func _on_cell_3_mouse_entered():
	selected = 2
func _on_cell_4_mouse_entered():
	selected = 3
func _on_cell_5_mouse_entered():
	selected = 4
func _on_cell_6_mouse_entered():
	selected = 5
