#Elijah Southman

extends VBoxContainer

var collapsedMenu = preload("res://Assets/Images/hud/OneDrive_1_4-12-2023/shop and herd exchange menus/elixir menu/shopElixirItemCollapsed.png")
var expandedMenu = preload("res://Assets/Images/hud/OneDrive_1_4-12-2023/shop and herd exchange menus/elixir menu/shopElixirItemExpandedwButtonV1.png")
var hovered = -1
var selected = -1
@onready var menus = [
	$Remedy,
	$Bulletstorm,
	$LifeLeech,
	$Roadrunner,
	$Lucky,
	$Dauntless
]
var numElixirTypes = [0, 0, 0, 0, 0, 0]
var elixirCosts = [0, 0, 0, 0, 0, 0]
@export var maxElixirs = 3
var parent = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(parent == null):
		parent = get_parent()
		updateNumElixirTypes()
		for i in 6:
			var potion = parent.player.potions[i]
			menus[i].find_child("Cost").text = str(potion.cost)
			elixirCosts[i] = potion.cost
			menus[i].find_child("Name").text = str(potion.name)
			menus[i].find_child("Name2").text = str(potion.name)
			menus[i].find_child("Icon").texture = potion.icon
			menus[i].find_child("Icon2").texture = potion.icon
			menus[i].find_child("Desc").text = str(potion.description)
	if(parent.active && visible):
		var mousePos = parent.viewport.get_mouse_position()
		var screen = parent.viewport.get_visible_rect()
		if(mousePos.x < screen.size.x - parent.widthOffset
		|| mousePos.y > screen.size.y - 50):
			hovered = -1
		
		if((Input.is_action_just_pressed("shoot") || Input.is_action_just_pressed("Interact"))
		&& hovered != -1):
			select(hovered)
		
func _physics_process(_delta):
	if(selected != -1 && parent.active && visible):
		var buyButton = menus[selected].find_child("Buy")
		if(parent.totalValue <= parent.player.potions[selected].cost || numElixirTypes[selected] > maxElixirs):
			if(numElixirTypes[selected] > maxElixirs):
				parent.level.broadcastMessage("Invalid Trade: Can't have more than " + maxElixirs + " of any elixir.", 0.1)
			else:
				parent.level.broadcastMessage("Invalid Trade: Insufficient cows.", 0.1)
			buyButton.disabled = true
			buyButton.modulate = Color(1.0, 0.75, 0.75)
		else:
			buyButton.disabled = false
			buyButton.modulate = Color(1.0, 1.0, 1.0)

func unselect(ind:int):
	var children = menus[ind].get_children()
	for i in children.size():
		if(i > 2):
			children[i].visible = false
			if("disabled" in children[i]):
				children[i].disabled = true
		else:
			children[i].visible = true
	menus[ind].texture_normal = collapsedMenu

func select(ind:int):
	if(selected == ind || ind == -1):
		return
	if(selected != -1):
		unselect(selected)
	parent.menuSounds.stream = parent.cowClick
	parent.menuSounds.play()
	selected = ind
	var children = menus[selected].get_children()
	for i in children.size():
		if(i > 2 && i < 9):
			children[i].visible = true
			if("disabled" in children[i]):
				children[i].disabled = false
		else:
			children[i].visible = false
	menus[selected].texture_normal = expandedMenu
	
		
func updateNumElixirTypes():
	if(parent.player == null):
		return
	numElixirTypes = parent.player.inventory
	for i in 6:
		menus[i].find_child("Num").text = str(numElixirTypes[i])
		menus[i].find_child("Num2").text = str(numElixirTypes[i])

func _on_remedy_mouse_entered():
	hovered = 0
func _on_bulletstorm_mouse_entered():
	hovered = 1
func _on_life_leech_mouse_entered():
	hovered = 2
func _on_roadrunner_mouse_entered():
	hovered = 3
func _on_lucky_mouse_entered():
	hovered = 4
func _on_dauntless_mouse_entered():
	hovered = 5

func cowSort(a, b):
	if(a.cowTypeInd < b.cowTypeInd):
		return true
	else:
		return false

func _on_buy_pressed():
	parent.menuSounds.stream = parent.tradeConfirm
	parent.menuSounds.play()
	var sum = 0
	var cows = parent.player.herd.getCows()
	var spentCows = []
	cows.sort_custom(cowSort)
	for i in cows.size():
		if(sum < elixirCosts[selected]):
			sum += parent.cowCosts[cows[i].cowTypeInd]
			spentCows.append(cows[i])
	var change = sum - elixirCosts[selected]
	for i in 6:
		var ind = 5 - i
		var num = change / parent.cowCosts[ind] as int
		change = change % parent.cowCosts[ind]
		for j in num:
			var cow = parent.player.herd.spawnCow(ind)
			cow.target = parent.player.position
	for i in spentCows:
		parent.player.herd.removeCow(i)
		i.queue_free()
	parent.player.inventory[selected] += 1
	parent.updateTotalValue()
	updateNumElixirTypes()
