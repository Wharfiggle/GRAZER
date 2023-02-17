extends Area

export var limitedLifetime:= false

var lifetime := [1.0, 2.0]

var tickSpeed := 0.05

var tick := 0.0

#var gravity := Vector3.UP

onready var tween := $Decay
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#func _ready():
	#if limitedLifetime:
		#tween.interpolate_property(self, "modulate:a", 1.0, 0.0, rand_range(lifetime[0], lifetime[1]), Tween.TRANS_CIRC, Tween.EASE_OUT)

#func _process(delta):
	#if tick > tickSpeed:
	#	tick = 0;
		
	#	for p in range(get_point_count()):
			
			#var rand_vector := Vector3
			
	#		points[p] += gravity
			
	
	#else:
	#	tick += delta


#func _on_Decay_tween_all_completed():
	#queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
