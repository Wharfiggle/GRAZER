#Elijah Southman

extends Node3D

@export var stage1:Array[String]
@export var stage2:Array[String]
@export var stage3:Array[String]
var stages
var index = -1
var stage = 0
@onready var textBox = $TextBox
@onready var player = get_node("/root/Level/Player")
@onready var usable = $Usable
var time = 0
@onready var textBoxOrigPos = textBox.position

# Called when the node enters the scene tree for the first time.
func _ready():
	stages = [[], [], []]
	for i in stage1:
		stages[0].append(load(i))
	for i in stage2:
		stages[1].append(load(i))
	for i in stage3:
		stages[2].append(load(i))
	textBox.visible = false

func use():
	if(index < stages[stage].size()):
		index += 1
		if(index == stages[stage].size()):
			textBox.visible = false
			index = -1
		else:
			textBox.visible = true
			textBox.set_texture(stages[stage][index])

func _process(delta):
	time += delta
	textBox.position.y = textBoxOrigPos.y + sin(time * 4.0) * 0.1

func setStage(s):
	stage = s
	index = -1
	textBox.visible = false
	usable.important = true
	usable.useOnEnter = true
