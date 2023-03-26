extends Label

var health = 0

func _ready():
	set("custom_colors/font_color", Color(0,1,1))

func updateHealth(hp):
	health = hp
	set_text("Health: " + str(health))
