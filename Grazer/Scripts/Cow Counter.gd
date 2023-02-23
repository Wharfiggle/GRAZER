extends Label

var cows = 0

func _ready():
	set("custom_colors/font_color", Color(0,1,1))

func updateCowNum(cowNum):
	cows = cowNum
	set_text("Cows: " + str(cows))
