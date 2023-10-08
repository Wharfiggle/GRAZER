extends Control

@onready var healthBarUnder = $Control/HBoxContainer/Bars/bar/Node2D/TextureProgressBar
@onready var healthBarOver = $Control/HBoxContainer/Bars/bar/Node2D/TextureProgressBar2
var tween : Tween
var ammoIcon = preload("res://Prefabs/templates/ammo.tscn")
var ammoBIcon = preload("res://Prefabs/templates/ammoBack.tscn")
@onready var ammoHolder = $ammoDisplay
@onready var AHBack = $ammoDisplay2
var PositionR = Vector2(150.0,653.0)
var PositionS = Vector2(230.0,653.0)
@onready var Wimage = $weponIcon

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

func _ammo_update_(AmmoAmount):
	#checks to see if the ammo counter has the right amount
	if(ammoHolder.get_children().size() < AmmoAmount):
		for i in (AmmoAmount - ammoHolder.get_children().size()):
			var ammoIcon_new = ammoIcon.instantiate()
			ammoHolder.add_child(ammoIcon_new, true)
		
	elif (ammoHolder.get_children().size() > AmmoAmount):
		#should remove the children until proper amount
		#var count = 0
		#print_debug(ammoHolder.get_children().size()- AmmoAmount)
		
		for i in (ammoHolder.get_children().size()- AmmoAmount):
			#ammoHolder.get_children()[ammoHolder.get_children().size() -1].queue_free()
			#count += 1
			
			_ammo_remove_(ammoHolder.get_children().size()- AmmoAmount)
			#print(count)
		

func _ammo_remove_( remove):
	for i in remove:
		#ammoHolder.get_child(0).queue_free()
		var cellone=ammoHolder.get_child(0)
		ammoHolder.remove_child(cellone)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	
func _on_health_update_(health):
	tween = create_tween()
	healthBarOver.value = health * 100
	healthBarUnder.value = health * 100
	
	tween.tween_property(healthBarUnder, "value", healthBarUnder.value, 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)



func _on_max_health_update_(maxHealth):
	healthBarOver.max_value =maxHealth
	healthBarUnder.max_value =maxHealth
	

func _set_weapon_image_(image):
	if(image == null):
		Wimage.visible = false
		ammoHolder.visible = false
		AHBack.visible = false
	else:
		Wimage.visible = true
		ammoHolder.visible = true
		AHBack.visible = true
		Wimage.set_texture(image)

func move_ammoHold_ (weapon:bool):
	if(weapon == true):
		ammoHolder.set_position(PositionR)
		AHBack.set_position(PositionR)
	elif (weapon == false):
		ammoHolder.set_position(PositionS)
		AHBack.set_position(PositionS)

func _set_ammo_Back (MaxAmmo):
	if(AHBack.get_children().size() < MaxAmmo):
		for i in (MaxAmmo - AHBack.get_children().size()):
			var ammoIcon_new = ammoBIcon.instantiate()
			AHBack.add_child(ammoIcon_new, true)
		
	elif (AHBack.get_children().size() > MaxAmmo):
		#should remove the children until proper amount
		var count = 0
		#print_debug(AHBack.get_children().size()- MaxAmmo)
		
		for i in (AHBack.get_children().size()- MaxAmmo):
			#ammoHolder.get_children()[ammoHolder.get_children().size() -1].queue_free()
			count += 1
			
			var celloneB=AHBack.get_child(0)
			AHBack.remove_child(celloneB)
			#print(count)
	
