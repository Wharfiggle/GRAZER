extends Area3D

@export var muzzle_velocity = 150
@export var lifespan = 4
var velocity
var damage
var from = ""
var source
var active = false
var hitBody = null
var hitPoint = null
@onready var raycast = get_node(NodePath("./RayCast3D"))
var bulletTrailMesh = preload("res://Prefabs/BulletTrailMesh.tres")
var bulletTrail
@onready var GunShot = $Boom
var GSSound = preload("res://sounds/desert-eagle-gunshot-14622.wav")
var range
var startPos
var trailPoints
@export var trailLength = 3.0
var trailEnd = 0

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
	velocity = Vector3(sin(rotation.y) * muzzle_velocity, 0, cos(rotation.y) * muzzle_velocity)
	range = inRange
	damage = inDamage
	active = true
	
	trailPoints = [Vector3.ZERO, Vector3.ZERO]
	#necessary to make the mesh independent from other bullets' trail meshes
	bulletTrail = bulletTrailMesh.duplicate()
	get_node(NodePath("./BulletTrail")).set_mesh(bulletTrail)
	
func _process(delta):
	lifespan -= delta
	if lifespan <= 0:
		queue_free()
		
	if(active && hitBody == null && hitPoint == null):
		position += velocity * delta
		
	if(active):
		var travelled = (position - startPos).length()
		if(travelled >= range - 0.5):
			stop()
			
		trailEnd = min(travelled, trailLength)
	else:
		trailLength -= muzzle_velocity * delta
		trailLength = max(trailLength, 0)
		trailEnd = min(trailEnd, trailLength)
	
	if(bulletTrail != null):
		trailPoints = [Vector3.ZERO, Vector3(0, 0, -trailEnd)]
		bulletTrail.updateTrail(trailPoints)

func _physics_process(delta):
	if(active):
		if(hitBody == null && hitPoint == null):
			if(raycast.is_colliding()): #if raycast is intercepted, move to hitPoint next frame
				hitBody = raycast.get_collider()
				var canHit = true
				if(hitBody.has_method("damage_taken")):
					canHit = hitBody.damage_taken(0, from)
				if(!canHit):
					hitBody = null
				else: #hits only if object doesn't have damage_taken or damage_taken returns true
					hitPoint = raycast.get_collision_point()
		elif(hitPoint != null): #if hitPoint was set last frame, move to hitPoint
			position = hitPoint
			hitPoint = null
		elif(hitBody != null): #if hitBody was set 2 frames ago, hurt the body
			hit(hitBody)

func hit(body):
	if(hitBody.has_method("damage_taken")):
		body.damage_taken(damage, from)
	stop()

func stop():
	active = false
	get_node(NodePath("./MeshInstance3D")).visible = false
