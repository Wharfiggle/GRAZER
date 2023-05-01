#Elijah Southman

extends VBoxContainer

var collapsedRevolver = preload("res://Assets/Images/hud/OneDrive_1_4-12-2023/shop and herd exchange menus/weapons menu/shopWeaponRevolvItemCollapsed.png")
var expandedRevolver = preload("res://Assets/Images/hud/OneDrive_1_4-12-2023/shop and herd exchange menus/weapons menu/shopWeaponRevolvItemExpanded.png")
var collapsedShotgun = preload("res://Assets/Images/hud/OneDrive_1_4-12-2023/shop and herd exchange menus/weapons menu/shopWeaponShotgunItemCollapsed.png")
var expandedShotgun = preload("res://Assets/Images/hud/OneDrive_1_4-12-2023/shop and herd exchange menus/weapons menu/shopWeaponShotgunItemExpanded.png")
var hovered = -1
var selected = -1
@onready var menus = [
	$Revolver,
	$Shotgun
]
var upgrades = []
var gunCosts = [0, 0, 0, 0, 0, 0]
var parent = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(parent == null):
		parent = get_parent()
		updateUpgrades()
	if(parent.active && visible):
		var mousePos = parent.viewport.get_mouse_position()
		var screen = parent.viewport.get_visible_rect()
		if(mousePos.x < screen.size.x - parent.widthOffset
		|| mousePos.y > screen.size.y - 50):
			hovered = -1
		
		if((Input.is_action_just_pressed("shoot") || Input.is_action_just_pressed("Interact"))
		&& hovered != -1):
			select(hovered)
	

func unselect(ind:int):
	menus[ind].find_child("Pips").visible = false
	menus[ind].find_child("Sections").visible = false
	menus[ind].get_node(NodePath("./Sections/Capacity/UpgradeCapacity")).disabled = true
	menus[ind].get_node(NodePath("./Sections/Damage/UpgradeDamage")).disabled = true
	menus[ind].get_node(NodePath("./Sections/Reload/UpgradeReload")).disabled = true
	if(ind == 0):
		menus[ind].texture_normal = collapsedRevolver
	else:
		menus[ind].texture_normal = collapsedShotgun

func select(ind:int):
	if(selected == ind || ind == -1):
		return
	if(selected != -1):
		unselect(selected)
	parent.menuSounds.stream = parent.cowClick
	parent.menuSounds.play()
	selected = ind
	menus[selected].find_child("Pips").visible = true
	menus[selected].find_child("Sections").visible = true
	menus[selected].get_node(NodePath("./Sections/Capacity/UpgradeCapacity")).disabled = false
	menus[selected].get_node(NodePath("./Sections/Damage/UpgradeDamage")).disabled = false
	menus[selected].get_node(NodePath("./Sections/Reload/UpgradeReload")).disabled = false
	if(selected == 0):
		menus[selected].texture_normal = expandedRevolver
	else:
		menus[selected].texture_normal = expandedShotgun
	updateUpgrades()
		
func updateUpgrades():
	if(parent.player == null):
		return
	upgrades = []
	for i in 6:
		var upgrade = parent.level.getUpgrade(i)
		upgrades.append(upgrade)
		var section = menus[i / 3].find_child("Sections").get_child(i % 3)
		section.find_child("Cost").text = str(upgrade.cost)
		gunCosts[i] = upgrade.cost
		var pips = menus[i / 3].find_child("Pips").get_children()
		for j in 3:
			if(upgrade.wepLevel == -1 || upgrade.wepLevel > j):
				pips[3 * (i % 3) + j].visible = true
		var buyButton = section.get_child(0)
		print("id: " + str(i) + ", cost: " + str(gunCosts[i]) + ", funds: " + str(parent.totalValue))
		if(upgrade.wepLevel == -1 || gunCosts[i] >= parent.totalValue):
			buyButton.disabled = true
			buyButton.modulate = Color(1.0, 0.75, 0.75)
		else:
			buyButton.disabled = false
			buyButton.modulate = Color(1.0, 1.0, 1.0)

func _on_revolver_mouse_entered():
	hovered = 0
func _on_shotgun_mouse_entered():
	hovered = 1

func cowSort(a, b):
	if(a.cowTypeInd < b.cowTypeInd):
		return true
	else:
		return false

func buy(section:int):
	parent.menuSounds.stream = parent.tradeConfirm
	parent.menuSounds.play()
	var sum = 0
	var cows = parent.player.herd.getCows()
	var spentCows = []
	cows.sort_custom(cowSort)
	for i in cows.size():
		if(sum < gunCosts[section]):
			sum += parent.cowCosts[cows[i].cowTypeInd]
			spentCows.append(cows[i])
	var change = sum - gunCosts[section]
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
	upgrades[section].use()
	parent.updateTotalValue()
	updateUpgrades()


func _on_revolver_upgrade_capacity_pressed():
	buy(0)
func _on_revolver_upgrade_damage_pressed():
	buy(1)
func _on_revolver_upgrade_reload_pressed():
	buy(2)
func _on_shotgun_upgrade_capacity_pressed():
	buy(3)
func _on_shotgun_upgrade_damage_pressed():
	buy(4)
func _on_shotgun_upgrade_reload_pressed():
	buy(5)
