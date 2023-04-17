extends Control

@onready var healthBarUnder = $Control/HBoxContainer/Bars/bar/Node2D/TextureProgressBar
@onready var healthBarOver = $Control/HBoxContainer/Bars/bar/Node2D/TextureProgressBar2
var tween : Tween
var ammoIcon = preload("res://Prefabs/templates/ammo.tscn")
@onready var ammoHolder = $ammoDisplay

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

func _ammo_update_(AmmoAmount):
	for i in AmmoAmount:
		var ammoIcon_new = ammoIcon.instantiate()
		ammoHolder.add_child(ammoIcon_new, true)
		
func _ammo_remove_():
	ammoHolder.get_child(0).queue_free()

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
