extends Area3D
@export var id = 0
var talking = false
var textDelay = 4.0
var timer = 5
var next = false
@onready var porchMan = get_parent()

#Make this a child of the talking porchman
var tutorial = []
var checkPoint = []
var index = -1
var textArray
var started = true
@onready var silentBox = preload("res://Assets/Images/SpeechBubbles/silenceBox.png")
var pointPoint
@onready var textBox = $"../TextBox"
@onready var player = get_node("/root/Level/Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	pointPoint = position - Vector3(silentBox.get_width(),0, silentBox.get_height())
	
	#Append all dialogue images in order
	
	
	#Dialogue for the tutorial porch man
	tutorial.append(["res://Assets/Images/SpeechBubbles/tutorialScript/Asset 11.png", 2])
	tutorial.append(["res://Assets/Images/SpeechBubbles/tutorialScript/Asset 12.png", 2])
	tutorial.append(["res://Assets/Images/SpeechBubbles/tutorialScript/Asset 13.png", 2])
	tutorial.append(["res://Assets/Images/SpeechBubbles/tutorialScript/Asset 14.png", 2])
	tutorial.append(["res://Assets/Images/SpeechBubbles/tutorialScript/Asset 15.png", 2])
	tutorial.append(["res://Assets/Images/SpeechBubbles/tutorialScript/Asset 16.png", 2])
	tutorial.append(["res://Assets/Images/SpeechBubbles/tutorialScript/Asset 17.png", 2])
	tutorial.append(["res://Assets/Images/SpeechBubbles/tutorialScript/Asset18.png", 7])
	tutorial.append(["res://Assets/Images/SpeechBubbles/tutorialScript/Asset19.png", 7])
	tutorial.append(["res://Assets/Images/SpeechBubbles/tutorialScript/Asset 20.png", 1])
	tutorial.append(["res://Assets/Images/SpeechBubbles/tutorialScript/Asset 21.png", 1])
	tutorial.append(["res://Assets/Images/SpeechBubbles/tutorialScript/Asset 22.png", 3])
	tutorial.append(["res://Assets/Images/SpeechBubbles/tutorialScript/Asset 23.png", 2])
	tutorial.append(["res://Assets/Images/SpeechBubbles/tutorialScript/Asset 24.png", 2])
	tutorial.append(["res://Assets/Images/SpeechBubbles/tutorialScript/Asset 25.png", 2])
	tutorial.append(["res://Assets/Images/SpeechBubbles/tutorialScript/Asset 26.png", 2])
	tutorial.append(["res://Assets/Images/SpeechBubbles/tutorialScript/Asset 27.png", 2])

	
	#Dialogue for the checkpoint porch men
	checkPoint.append(["res://Assets/Images/SpeechBubbles/porchMan&Woman shopLines/Asset 30.png", 3])
	checkPoint.append(["res://Assets/Images/SpeechBubbles/porchMan&Woman shopLines/Asset 31.png", 3])
	checkPoint.append(["res://Assets/Images/SpeechBubbles/porchMan&Woman shopLines/Asset 32.png", 3])
	checkPoint.append(["res://Assets/Images/SpeechBubbles/porchMan&Woman shopLines/Asset 33.png", 3])
	checkPoint.append(["res://Assets/Images/SpeechBubbles/porchMan&Woman shopLines/Asset 34.png", 3])
	checkPoint.append(["res://Assets/Images/SpeechBubbles/porchMan&Woman shopLines/Asset 35.png", 3])

	if(id == 0):
		textArray = tutorial
	elif(id == 1):
		textArray = checkPoint

func start():
	started = true
	#visible = true
	textBox.visible = true

func use():
	print("used")
	if(!started):
		start()
	nextText()

func nextText():
	if(started and textBox != null and index < textArray.size() - 1):
		index += 1
		#timer = textArray[index][1] * 3
		textBox.set_texture(load(textArray[index][0]))
		if(textArray[index][0] == "res://Assets/Images/SpeechBubbles/tutorialScript/Asset18.png"):
			textBox.scale = Vector3(1.3,1.3,1.3)
		elif(textArray[index][0] == "res://Assets/Images/SpeechBubbles/tutorialScript/Asset 20.png"):
			textBox.scale = Vector3(2,2,2)
	#Hide when done talking
	elif(started and textBox != null):
		visible = false
		started = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#func _on_body_entered(body):
#	if(body.is_in_group('Player') and !started):
#		start()
