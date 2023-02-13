extends Label

func _ready():
	set("custom_colors/font_color", Color(0,0,1))

func _process(_delta: float) -> void:
	set_text("FPS: " + String(Engine.get_frames_per_second()))
