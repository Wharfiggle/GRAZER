#Elijah Southman

extends TextureRect

@export var enterExitTime = 0.2
var enterExitTimer = 0.0
@export var widthOffset = 340
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
var numCowTypes = null
@onready var uiCursor = get_node(NodePath("/root/Level/UICursor"))
@onready var camera = get_node(NodePath("/root/Level/Camera3D"))
@onready var level = get_node(NodePath("/root/Level"))
@export var cowCosts = [1, 3, 3, 6, 6, 12]
var lastRecordedCowNum = -1
var totalValue = 0
var hoveredCow = null
var selectedCows = []
var selectedValue = 0
var gain = 0
var change = 0
var tradeMenu = null
@export var maxCows = 30

@onready var menuSoundsB = $AudioStreamPlayer
var openSound = preload("res://sounds/New Sound FEX/UI/MenuSlideIn.wav")
var closeSound = preload("res://sounds/New Sound FEX/UI/MenuSlideOutedited.wav")
var tradeSound = preload("res://sounds/New Sound FEX/UI/cow menu/CowOfferTrade.wav")
var tradeCancel = preload("res://sounds/New Sound FEX/UI/cow menu/CowMenuBack.wav")
var tradeConfirm = preload("res://sounds/New Sound FEX/UI/cow menu/CowConfirmTrade.wav")
var cowClick = preload("res://sounds/New Sound FEX/UI/Scroll.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	position.x = origPos.x + widthOffset
	for i in cowCosts.size():
		cowMenus[i].find_child("Cost").text = str(cowCosts[i])

func use(turnOff:bool = false):
	if(turnOff && !active):
		return
	stopTrade()
	active = !active
	enterExitTimer = enterExitTime
	if(active):
		level.changeMusic(3)
		menuSoundsB.stream = openSound
		menuSoundsB.play()
		updateNumCowTypes()
		updateTotalValue()
		var newMousePos = Vector2(
			viewport.get_visible_rect().size.x - widthOffset,
			viewport.get_visible_rect().size.y / 2)
		uiCursor.global_position = newMousePos
		uiCursor.setActive(true, newMousePos)
		player.active = false
	else:
		level.changeMusic(2)
		menuSoundsB.stream =closeSound
		menuSoundsB.play()
		uiCursor.setActive(false)
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
		var mousePos = viewport.get_mouse_position()
		var screen = viewport.get_visible_rect()
		if(mousePos.x < screen.size.x - widthOffset
		|| mousePos.y > screen.size.y - 50):
			hovered = -1
		
		if((Input.is_action_just_pressed("shoot") || Input.is_action_just_pressed("Interact"))
		&& hovered != -1):
			select(hovered)
		
		if(Input.is_action_just_pressed("dodge")):
			if(trading):
				stopTrade()
			else:
				use(true)
		
		if(trading):
			if(hoveredCow != null):
				if(hoveredCow.uiSelectMode == 1):
					hoveredCow.uiSelectMode = 0
				hoveredCow = null
			var ray_query = PhysicsRayQueryParameters3D.new()
			ray_query.from = camera.project_ray_origin(mousePos)
			ray_query.to = ray_query.from + camera.project_ray_normal(mousePos) * 100
			ray_query.set_collision_mask(0b1000)
			var collision = player.get_world_3d().direct_space_state.intersect_ray(ray_query)
			var collider = collision.get("collider", null)
			if(!collision.is_empty() && collider.has_method("startDragging")):
				hoveredCow = collider
			
			if(hoveredCow != null):
				if(Input.is_action_just_pressed("shoot")):
					selectCow(hoveredCow)
#				elif(Input.is_action_just_pressed("dodge")):
#					unselectCow(hoveredCow)
				elif(hoveredCow.uiSelectMode == 0):
					hoveredCow.uiSelectMode = 1
		

func _physics_process(_delta):
	if(visible && player != null && player.herd != null && level != null):
		var cowNum = player.herd.getNumCows()
		if(cowNum != lastRecordedCowNum):
			lastRecordedCowNum = cowNum
			updateNumCowTypes()
			updateTotalValue()
		if(trading):
			if(gain == 0):
				level.broadcastMessage("Invalid Trade: Results in zero cows.", 0.1)
			if(maxCows < player.herd.getNumCows() + gain + change - selectedCows.size()):
				level.broadcastMessage("Invalid Trade: You cannot exceed " + str(maxCows) + " cows.", 0.1)
	elif(player == null):
		player = get_node(NodePath("/root/Level/Player"))
	elif(level == null):
		level = get_node(NodePath("/root/Level"))

func unselect(ind:int):
	if(trading):
		stopTrade()
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
	if(selected == ind || ind == -1):
		return
	if(selected != -1):
		unselect(selected)
	menuSoundsB.stream = cowClick
	menuSoundsB.play()
	selected = ind
	var children = cowMenus[selected].get_children()
	for i in children.size():
		if(i > 2 && i < 9):
			children[i].visible = true
			if("disabled" in children[i]):
				children[i].disabled = false
		else:
			children[i].visible = false
	cowMenus[selected].texture_normal = expandedMenu
	
func startTrade():
	trading = true
	tradeMenu = cowMenus[selected].find_child("TradeMenu")
	tradeMenu.visible = true
	tradeMenu.get_child(3).disabled = false
	tradeMenu.get_child(4).disabled = false
	updateTrade()

func updateTrade():
	gain = selectedValue / cowCosts[selected] as int
	change = selectedValue % cowCosts[selected]
	tradeMenu.get_child(0).get_child(0).text = str(selectedValue)
	tradeMenu.get_child(1).get_child(0).text = str(gain)
	tradeMenu.get_child(2).get_child(0).text = str(change)
	var cows = player.herd.getCows()
	for i in cows:
		if(i.uiSelectMode == -1):
			i.uiSelectMode = 0
	var confirmTradeButton = tradeMenu.find_child("ConfirmTrade")
	if(gain == 0 || maxCows < player.herd.getNumCows() + gain + change - selectedCows.size()):
		confirmTradeButton.disabled = true
		confirmTradeButton.modulate = Color(1.0, 0.75, 0.75)
	else:
		confirmTradeButton.disabled = false
		confirmTradeButton.modulate = Color(1.0, 1.0, 1.0)
	
func stopTrade():
	if(!trading):
		return
	trading = false
	tradeMenu.visible = false
	tradeMenu.get_child(3).disabled = true
	tradeMenu.get_child(4).disabled = true
	var cows = player.herd.getCows()
	for i in cows:
		i.uiSelectMode = -1
	hoveredCow = null
	selectedCows.clear()
	selectedValue = 0
	gain = 0
	change = 0
	menuSoundsB.stream = tradeCancel
	menuSoundsB.play()
	
func confirmTrade():
	for i in gain:
		var cow = player.herd.spawnCow(selected)
#		cow.target = player.position
	var remainingChange = change
	for i in 6:
		var ind = 5 - i
		var num = remainingChange / cowCosts[ind] as int
		remainingChange = remainingChange % cowCosts[ind] 
		for j in num:
			var cow = player.herd.spawnCow(ind)
#			cow.target = player.position
	for i in selectedCows.size():
		player.herd.removeCow(selectedCows[i])
		selectedCows[i].queue_free()
	stopTrade()
	
func selectCow(cow:Node):
	if(selectedCows.has(cow)):
		unselectCow(cow)
	else:
		selectedCows.append(cow)
		selectedValue += cowCosts[cow.cowTypeInd]
		cow.uiSelectMode = 2
		updateTrade()

func unselectCow(cow:Node):
	if(selectedCows.has(cow)):
		selectedCows.erase(cow)
		selectedValue -= cowCosts[cow.cowTypeInd]
		cow.uiSelectMode = 0
		updateTrade()
		
func updateNumCowTypes():
	if(player == null):
		return
	numCowTypes = [0, 0, 0, 0, 0, 0]
	var cows = player.herd.getCows()
	for i in cows.size():
		numCowTypes[cows[i].cowTypeInd] += 1
	for i in 6:
		cowMenus[i].find_child("Num").text = str(numCowTypes[i])
		cowMenus[i].find_child("Num2").text = str(numCowTypes[i])

func updateTotalValue():
	if(player == null):
		return
	var cows = player.herd.getCows()
	totalValue = 0
	for i in cows.size():
		totalValue += cowCosts[cows[i].cowTypeInd]
	find_child("TotalValue").text = str(totalValue)

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

func _on_confirm_trade_pressed():
	menuSoundsB.stream = tradeConfirm
	menuSoundsB.play()
	confirmTrade()

func _on_make_trade_pressed():
	menuSoundsB.stream =tradeSound
	menuSoundsB.play()
	startTrade()
