extends CharacterBody3D
 ##This needs to be added to an enemy
var vel = Vector3(0,0,0)

var gravity = 30
var speed = velocity
var knock = Vector3(0,0,0)
var lifespan = 10

@export var knockable = true
@export var knockbackMod = 5

@onready var sound = $"../enemy2/TestPlayer3D"

var walk = preload("res://sounds/desert-eagle-gunshot-14622.wav")
var mar = preload("res://sounds/VOX-marauder01.wav")
var soundtime = 0.0
var hit = 2

var maxHP = 10

var HP = maxHP
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	sound.stream = mar
	sound.play()
	pass # Replace with function body.

func knockback(damageSourcePos:Vector3, recivedDamage:int):
	#speed = push * zoom
	
	if knockable:
		var knockbackDirection = self.position.direction_to(damageSourcePos)
		var knockbackStrength = recivedDamage * knockbackMod 
		var knockB = knockbackDirection * knockbackStrength
		
		global_position += knockB
		damage_taken(hit, knockbackDirection)
	

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	speed = speed.move_toward(velocity, 100 * delta)
	
	speed.y = speed.y - gravity*delta
	if is_on_floor():
		speed.y = -0.1
	
	set_velocity(speed)
	move_and_slide()
	speed = velocity
	


func damage_taken(damage, from)-> bool:
		soundtime = 3.0
		sound.stream= walk
		HP -= damage
		
		if HP <= 0:
			queue_free()
		return true
	
	

func _process(delta):
	
		if soundtime > 0:
			print("im in")
			if !sound.playing:
				sound.play()
			soundtime -=delta
		
