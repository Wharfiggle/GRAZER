#Elijah Southman
extends AudioStreamPlayer

@onready var origVolume = volume_db
var transitionTime = 1.0
var transitionTimer = 0
var fadingIn = true
var muted = false

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

func mute(mute:bool = true):
	muted = mute
	if(muted):
		set_volume_db(-80)
	elif(fadingIn):
		set_volume_db(origVolume)

func _ready():
	if(!autoplay):
		set_volume_db(-80)
		fadingIn = false
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
		if(!muted):
			set_volume_db(t * (origVolume - -80) - 80)
		else:
			set_volume_db(-80)
		
		#if(!fadingIn): print(volume_db)
	
func _on_finished():
	play()
