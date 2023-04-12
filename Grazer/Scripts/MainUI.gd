extends MarginContainer

@onready var healthBar = $HBoxContainer/Bars/bar/TextureProgressBar

@onready var tween = get_tree().create_tween()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	pass



func _on_health_update_(health):
	healthBar.value=health
	
	#tween.tween_property(healthBar, "value", healthBar.value, 0.5).set_trans(Tween.TRANS_BOUNCE)
	


func _on_max_health_update_(maxHealth):
	healthBar.max_value =maxHealth
