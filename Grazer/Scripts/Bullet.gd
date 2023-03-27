extends Area3D

@export var muzzle_velocity = 150
@export var lifespan = 8
var velocity = Vector3.ZERO
var damage
var from = ""
var source
var active = false
var smoke = preload("res://Prefabs/Smoke.tscn")
#var waitForSmoke = 0
var hitBody = null
var hitPoint = null
@onready var raycast = get_node(NodePath("./RayCast3D"))
@onready var GunShot = $Boom
var GSSound = preload("res://sounds/desert-eagle-gunshot-14622.wav")
var range
var startPos

# Called when the node enters the scene tree for the first time.
func _ready():
	#selecting sound
	GunShot.stream = GSSound
	#begining sound play
	GunShot.play()
	raycast.target_position = Vector3(0, -muzzle_velocity / 60.0, 0)

func shoot(inSource:Node3D, inFrom:String, inPosition:Vector3, inRotation:Vector3, 
inRange:float, inDamage:float):
	source = inSource
	source.get_parent().add_child(self)
	from = inFrom
	global_position = inPosition
	startPos = inPosition
	rotation = inRotation
	range = inRange
	damage = inDamage
	active = true
	
func _process(delta):
	lifespan -= delta
	if lifespan <= 0:
		queue_free()

func _physics_process(delta):
#	if(waitForSmoke == 0):
#		var smokeInstance = smoke.instantiate()
#		smokeInstance.rotation = Vector3.ZERO
#		add_child(smokeInstance)
#		smokeInstance.global_position = global_position
#		waitForSmoke += 1
	
	if(active):
		if(velocity == Vector3.ZERO):
			velocity = Vector3(sin(rotation.y) * muzzle_velocity, 0, cos(rotation.y) * muzzle_velocity)
		if(hitBody == null):
			position += velocity * delta
		
		if(hitPoint != null): #if hitPoint was set last frame, move to hitPoint
			position = hitPoint
			hitPoint = null
		elif(hitBody != null): #if hitBody was set 2 frames ago, hurt the body
			hit(hitBody)
		if(raycast.is_colliding()): #if raycast is intercepted, move to hitPoint next frame
			hitBody = raycast.get_collider()
			var canHit = true
			if(hitBody.has_method("damage_taken")):
				canHit = hitBody.damage_taken(0, from)
			if(!canHit):
				hitBody = null
			else: #hits only if object doesn't have damage_taken or damage_taken returns true
				hitPoint = raycast.get_collision_point()
		var travelled = abs((position - startPos).length())
		if(travelled > range):
			stop()

func hit(body):
	if(hitBody.has_method("damage_taken")):
		body.damage_taken(damage, from)
	stop()

func stop():
	active = false
	get_node(NodePath("./MeshInstance3D")).visible = false
#	var particles = get_node(NodePath("./Smoke")).get_children()
#	for i in particles:
#		i.emitting = false
