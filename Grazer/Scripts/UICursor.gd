extends Control

@export var active = false
#var velocity = Vector2.ZERO
@export var speed = 1000.0
@onready var viewport = get_viewport()
@onready var prevMousePos = Vector2(-1, -1)
var stickMoved = false

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = active

func setActive(inActive:bool, inPos:Vector2 = Vector2(-1, -1)):
	active = inActive
	if(active && inPos != Vector2(-1, -1)):
		setPosition(inPos)
		prevMousePos = global_position
		viewport.warp_mouse(global_position)
	visible = active
	
func setPosition(inPos:Vector2):
	global_position = inPos
	var screen = viewport.get_visible_rect()
	var bound1 = screen.position
	var bound2 = bound1 + screen.size
	global_position.x = min(max(global_position.x, bound1.x), bound2.x)
	global_position.y = min(max(global_position.y, bound1.y), bound2.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!active):
		return
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var mousePos = viewport.get_mouse_position()
	var screen = viewport.get_visible_rect()
	var bound1 = screen.position
	var bound2 = bound1 + screen.size
	var inBounds = (mousePos.x >= bound1.x && mousePos.x < bound2.x 
		&& mousePos.y >= bound1.y && mousePos.y < bound2.y)
	if(!stickMoved && prevMousePos != mousePos && inBounds):
		if(prevMousePos == Vector2(-1, -1)):
			setPosition(mousePos)
		else:
			print(str(mousePos) + " " + str(prevMousePos))
			setPosition(global_position + mousePos - prevMousePos)
		prevMousePos = mousePos
	else:
		if(stickMoved):
			stickMoved = false
		if(!inBounds):
			prevMousePos = Vector2(-1, -1)
		var leftStick = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
		var rightStick = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
		var stick = null
		if(leftStick.length() > 0.2):
			stick = leftStick
		elif(rightStick.length() > 0.2):
			stick = rightStick
		if(stick != null):
			var newPos = global_position + stick * speed * delta
			setPosition(newPos)
			viewport.warp_mouse(newPos)
			stickMoved = true
			prevMousePos = newPos
		
	if(Input.is_action_just_pressed("Interact")):
		var a = InputEventMouseButton.new()
		var screenSize = DisplayServer.window_get_size() as Vector2
		a.position = global_position
		a.position *= screenSize / Vector2(1280.0, 720.0)
#		var xratio = 1 / (1280 / screenSize.x)
#		var yratio = 1 / (720 / screenSize.y)
#		if(yratio < xratio):
#			var blackBar = (screenSize.x - (1280.0 * yratio)) / 2.0
#			a.position.x += blackBar
#			print("x " + str(blackBar))
#		if(yratio > xratio):
#			var blackBar = (screenSize.y - (720.0 * xratio)) / 2.0
#			a.position.y += blackBar
#			print("y " + str(blackBar))
		a.button_index = MOUSE_BUTTON_LEFT
		a.pressed = true
		Input.parse_input_event(a)
		await get_tree().process_frame
		a.pressed = false
		Input.parse_input_event(a)
