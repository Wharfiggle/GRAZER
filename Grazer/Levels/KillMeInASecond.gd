extends StaticBody3D

@export var time = 1.0
@onready var timer = time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer -= delta
	if(timer <= 0):
		queue_free()
