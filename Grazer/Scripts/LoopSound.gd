#Elijah Southman
extends AudioStreamPlayer

@onready var origVolume = volume_db
var transitionTime = 1.0
var transitionTimer = 0
var fadingIn = true

func fadeOut(transition_duration = 0.5):
	transitionTime = transition_duration
	transitionTimer = transitionTime
	fadingIn = false
	volume_db = origVolume

func fadeIn(transition_duration = 0.5):
	transitionTime = transition_duration
	transitionTimer = transitionTime
	fadingIn = true
	volume_db = -80

func _ready():
	if(!autoplay):
		set_volume_db(-80)
		play()

func _process(delta):
	if(transitionTimer > 0 || transitionTimer == transitionTime):
		transitionTimer -= delta
		if(transitionTimer < 0):
			transitionTimer = 0
		
		var t = transitionTimer / transitionTime
		if(fadingIn):
			t = 1 - t
		t = sqrt(t)
		set_volume_db(t * (origVolume - -80) - 80)
		
		#if(!fadingIn): print(volume_db)
	
func _on_finished():
	play()
