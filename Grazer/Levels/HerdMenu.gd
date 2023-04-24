extends TextureRect

@export var enterExitTime = 0.2
var enterExitTimer = 0.0
@export var widthOffset: float
@onready var origPos = position
var active = false
@onready var viewport = get_viewport()
@onready var player = get_node(NodePath("/root/Level/Player"))
var collapsedMenu = preload("res://Assets/Images/hud/OneDrive_1_4-12-2023/shop and herd exchange menus/herd exchange menu/shopHerdItemCollapsed.png")
var expandedMenu = preload("res://Assets/Images/hud/OneDrive_1_4-12-2023/shop and herd exchange menus/herd exchange menu/shopHerdItemExpandedInfoStage.png")
var hovered = -1
var selected = -1
var trading = false
@onready var cowMenus = [
	$VBoxContainer/Common,
	$VBoxContainer/Red,
	$VBoxContainer/Lucky,
	$VBoxContainer/GrandRed,
	$VBoxContainer/Ironhide,
	$VBoxContainer/Moxie
]

# Called when the node enters the scene tree for the first time.
func _ready():
	position.x = origPos.x + widthOffset

func use():
	active = !active
	enterExitTimer = enterExitTime
	if(active):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var newMousePos = Vector2(
			viewport.get_visible_rect().size.x - widthOffset,
			viewport.get_visible_rect().size.y / 2)
		viewport.warp_mouse(newMousePos)
		player.active = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		player.active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(enterExitTimer > 0):
		enterExitTimer -= delta
		if(enterExitTimer <= 0):
			enterExitTimer = 0
		var t = enterExitTimer / enterExitTime
		if(!active):
			t = (enterExitTime - enterExitTimer) / enterExitTime
		t = pow(t, 2)
		position.x = origPos.x + widthOffset * t
	
	if(active):
		if(viewport.get_mouse_position().x < viewport.get_visible_rect().size.x - widthOffset):
			hovered = -1
		
		if((Input.is_action_just_pressed("shoot") || Input.is_action_just_pressed("Interact")) 
		&& hovered != -1):
			select(hovered)
		
		if(Input.is_action_just_pressed("dodge")):
			use()

func unselect(ind:int):
	var children = cowMenus[ind].get_children()
	for i in children.size():
		if(i > 2):
			children[i].visible = false
			if("disabled" in children[i]):
				children[i].disabled = true
		else:
			children[i].visible = true
	cowMenus[ind].texture_normal = collapsedMenu

func select(ind:int):
	if(selected != -1):
		unselect(selected)
	selected = ind
	var children = cowMenus[selected].get_children()
	for i in children.size():
		if(i > 2):
			children[i].visible = true
			if("disabled" in children[i]):
				children[i].disabled = false
		else:
			children[i].visible = false
	cowMenus[selected].texture_normal = expandedMenu
	
func stopTrade():
	pass

func startTrade():
	pass

func _on_common_mouse_entered():
	hovered = 0
func _on_red_mouse_entered():
	hovered = 1
func _on_lucky_mouse_entered():
	hovered = 2
func _on_grand_red_mouse_entered():
	hovered = 3
func _on_ironhide_mouse_entered():
	hovered = 4
func _on_moxie_mouse_entered():
	hovered = 5
