extends Control

var invintory = []
var maxinvtory = 9
# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	pass # Replace with function body.
#needs to be set on a node that always is prossessing
func pause ():
	#checking if the game is paused or not
	
	if (!get_tree().paused):
		#pauses all the nodes thats prossessing is set to inharent
		get_tree().paused = true
	elif(get_tree().paused):
		#unpauses all the nodes thats prossessing is set to inharent
		get_tree().paused = false
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if(Input.is_action_just_pressed("openInvi")):
		#checking if invintory is open or not
		
		if (!self.visible):
			#makes the menu visable
			self.visible = true
			pause()
			#makes the mouse apper
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif (self.visible):
			#makes the menu vanish
			self.visible = false 
			pause()
			#makes the mouse hide
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			
	pass


