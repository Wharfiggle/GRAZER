#Elijah Southman

extends TextureRect

@export var enterExitTime = 0.2
var enterExitTimer = 0.0
@export var widthOffset = 340
@onready var origPos = position
var active = false
var onElixirMenu = false
@onready var elixirMenu = find_child("ElixirMenu")
@onready var gunMenu = find_child("GunMenu")
@onready var viewport = get_viewport()
@onready var player = get_node(NodePath("/root/Level/Player"))
@export var cowCosts = [1, 3, 3, 6, 6, 12]
var elixirMenuTexture = preload("res://Assets/Images/hud/shopWholeElixirTab_oneShadow.png")
var gunMenuTexture = preload("res://Assets/Images/hud/shopWholeWeaponsTab_oneShadow.png")
var hovered = -1
var selected = -1
var numCowTypes = null
@onready var uiCursor = get_node(NodePath("/root/Level/UICursor"))
@onready var camera = get_node(NodePath("/root/Level/Camera3D"))
@onready var level = get_node(NodePath("/root/Level"))
var lastRecordedCowNum = -1
var totalValue = 0

@onready var menuSounds = $AudioStreamPlayer
var openSound = preload("res://sounds/New Sound FEX/UI/MenuSlideIn.wav")
var closeSound = preload("res://sounds/New Sound FEX/UI/MenuSlideOutedited.wav")
var tradeSound = preload("res://sounds/New Sound FEX/UI/cow menu/CowOfferTrade.wav")
var tradeCancel = preload("res://sounds/New Sound FEX/UI/cow menu/CowMenuBack.wav")
var tradeConfirm = preload("res://sounds/New Sound FEX/UI/cow menu/CowConfirmTrade.wav")
var cowClick = preload("res://sounds/New Sound FEX/UI/Scroll.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	position.x = origPos.x + widthOffset
	

func use():
	active = !active
	enterExitTimer = enterExitTime
	if(active):
		menuSounds.stream = openSound
		menuSounds.play()
		updateTotalValue()
		var newMousePos = Vector2(
			viewport.get_visible_rect().size.x - widthOffset,
			viewport.get_visible_rect().size.y / 2)
		uiCursor.setActive(true, newMousePos)
		player.active = false
	else:
		menuSounds.stream =closeSound
		menuSounds.play()
		uiCursor.setActive(false)
		player.active = true

func _physics_process(_delta):
	if(visible && player != null && player.herd != null && level != null):
		var cowNum = player.herd.getNumCows()
		if(cowNum != lastRecordedCowNum):
			lastRecordedCowNum = cowNum
			updateTotalValue()
	elif(player == null):
		player = get_node(NodePath("/root/Level/Player"))
	elif(level == null):
		level = get_node(NodePath("/root/Level"))

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
		
		if(Input.is_action_just_pressed("SwapMenu")):
			swapMenu()
		elif(Input.is_action_just_pressed("dodge")):
			use()

func setMenu(elixir:bool):
	if(elixir && !onElixirMenu):
		swapMenu()
	elif(!elixir && onElixirMenu):
		swapMenu()

func swapMenu():
	menuSounds.stream = cowClick
	menuSounds.play()
	onElixirMenu = !onElixirMenu
	if(onElixirMenu):
		texture = elixirMenuTexture
		elixirMenu.visible = true
		gunMenu.visible = false
	else:
		texture = gunMenuTexture
		elixirMenu.visible = false
		gunMenu.visible = true

func updateTotalValue():
	if(player == null):
		return
	var cows = player.herd.getCows()
	totalValue = 0
	for i in cows.size():
		totalValue += cowCosts[cows[i].cowTypeInd]
	find_child("TotalValue").text = str(totalValue)

func _on_swap_menu_right_2_pressed():
	setMenu(true)
func _on_swap_menu_left_2_pressed():
	setMenu(false)
