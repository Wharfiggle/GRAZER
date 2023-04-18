extends Control

var inventory = []
@export var maxInventory = 6
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
@onready var origScale = cells[0].size.x
var wheelRadius = 80

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

#needs to be set on a node that always is prossessing
func pause ():
	#checking if the game is paused or not
	if (!get_tree().paused):
		#pauses all the nodes thats prossessing is set to inharent
		get_tree().paused = true
	elif(get_tree().paused):
		#unpauses all the nodes thats prossessing is set to inharent
		get_tree().paused = false
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(Input.is_action_just_pressed("ItemWheel")):
		#checking if inventory is open or not
		if(!visible):
			#makes the menu visable
			visible = true
			pause()
			#makes the mouse appear
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif(visible):
			#makes the menu vanish
			visible = false
			pause()
			#makes the mouse hide
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			highlight = [0, 0, 0, 0, 0, 0]
			selected = -1
			for i in cells.size():
				cells[i].modulate.a = origTransparency
				cells[i].size = Vector2(origScale, origScale)
	if(visible):
		for i in highlight.size():
			var target = 1.0
			if(selected != i):
				target = 0.0
			highlight[i] = lerpf(highlight[i], target, 0.1)
			cells[i].modulate.a = origTransparency + (1 - origTransparency) * highlight[i]
			var newScale = origScale + (1 - origScale) * highlight[i]
			cells[i].size = Vector2(newScale, newScale)
			
		var mousePos = get_viewport().get_mouse_position()
		if(mousePos.length() > wheelRadius):
			selected = -1

func _on_cell_1_mouse_entered():
	selected = 0
	print("mouse entered top cell")
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
