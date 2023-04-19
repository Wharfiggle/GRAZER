extends Control

@onready var healthBarUnder = $Control/HBoxContainer/Bars/bar/Node2D/TextureProgressBar
@onready var healthBarOver = $Control/HBoxContainer/Bars/bar/Node2D/TextureProgressBar2
var tween : Tween
var ammoIcon = preload("res://Prefabs/templates/ammo.tscn")
@onready var ammoHolder = $ammoDisplay
var PositionR = Vector2(153.0,653.0)
@onready var Wimage = $weponIcon

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

func _ammo_update_(AmmoAmount):
	#checks to see if the ammo counter has the right amount
	print_debug("update called")
	if(ammoHolder.get_children().size() < AmmoAmount):
		for i in (AmmoAmount - ammoHolder.get_children().size()):
			var ammoIcon_new = ammoIcon.instantiate()
			ammoHolder.add_child(ammoIcon_new, true)
		
	elif (ammoHolder.get_children().size() > AmmoAmount):
		#should remove the children until proper amount
		var count = 0
		print_debug(ammoHolder.get_children().size()- AmmoAmount)
		
		for i in (ammoHolder.get_children().size()- AmmoAmount):
			#ammoHolder.get_children()[ammoHolder.get_children().size() -1].queue_free()
			count += 1
			
			_ammo_remove_(ammoHolder.get_children().size()- AmmoAmount)
			print(count)
		

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
	healthBarOver.value = health * 10
	healthBarUnder.value = health * 10
	
	tween.tween_property(healthBarUnder, "value", healthBarUnder.value, 2.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)



func _on_max_health_update_(maxHealth):
	healthBarOver.max_value =maxHealth
	healthBarUnder.max_value =maxHealth
	

func _set_weapon_image_(image):
	Wimage.set_texture(image)

func move_ammoHold_ ():
	ammoHolder.set_position()
