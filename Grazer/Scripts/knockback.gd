extends CharacterBody3D
 ##This needs to be added to an enemy
var vel = Vector3(0,0,0)

var gravity = 30
var speed = velocity
var knock = Vector3(0,0,0)
var lifespan = 10

@export var knockable = true

@export var knockbackMod = 0.1


var maxHP = 10

var HP = maxHP
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func knockback(damageSourcePos:Vector3, recivedDamage:int):
	#speed = push * zoom
	
	if knockable:
		var knockbackDirection = damageSourcePos.direction_to(self.global_position)
		var knockbackStrength = recivedDamage * knockbackMod
		var knockB = knockbackDirection * knockbackStrength
		
		global_position += knockB
	

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
	


func damage_taken(damage):
	HP -= damage
	
	if HP <= 0:
		print("Wasted")
	
