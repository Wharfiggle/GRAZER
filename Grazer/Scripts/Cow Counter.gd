extends Label

var cows = 0

func _ready():
	set("custom_colors/font_color", Color(0,1,1))

func _process(_delta: float) -> void:
	set_text("Cows: " + str(cows))
