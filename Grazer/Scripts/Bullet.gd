#Elijah Southman
extends Area3D

@export var muzzle_velocity = 150.0
@export var lifespan = 4.0
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
var bulletRange
var startPos
var trailPoints
@export var trailLength = 3.0
var trailEnd = 0
var bulletStopExtend = 0
var trailColor = Color(1, 167 / 255.0, 0)
var critHit = false
@onready var boom = $Boom
var hitSound = preload("res://sounds/Enemy Stuff/BulletImpact(Enemy).wav")
var player
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	raycast.target_position = Vector3(0, -muzzle_velocity / 60.0, 0)
	rng.randomize()
	bulletStopExtend = rng.randf_range(0, 1)
	

func shoot(inSource:Node3D, inFrom:String, inPosition:Vector3, inRotation:Vector3, 
inRange:float, inDamage:float, inCritHit:bool = false, inColor:Color = Color(-1,-1,-1), inSpeed:float = 150.0):
	source = inSource
	source.get_parent().add_child(self)
	if(source.is_in_group("Player")):
		player = source
	else:
		player = get_node(NodePath("/root/Level/Player"))
#	if(boom.stream != null):
#		player.extraSounds.set_stream(boom.stream)
#		player.extraSounds.play(.55)
	from = inFrom
	global_position = inPosition
	startPos = inPosition
	rotation = inRotation
	muzzle_velocity = inSpeed
	velocity = Vector3(sin(rotation.y) * muzzle_velocity, 0, cos(rotation.y) * muzzle_velocity)
	bulletRange = inRange
	damage = inDamage
	active = true
	critHit = inCritHit
	
	trailPoints = [Vector3.ZERO, Vector3.ZERO]
	#necessary to make the mesh independent from other bullets' trail meshes
	bulletTrail = bulletTrailMesh.duplicate()
	var meshInstance = get_node(NodePath("./BulletTrail"))
	meshInstance.set_mesh(bulletTrail)
	if(inColor != null && inColor.r != -1):
		#print("set bullet trail to " + str(inColor))
		bulletTrail.prepareForColorChange(meshInstance)
		bulletTrail.setColor(inColor)
		trailColor = inColor
	
func _process(delta):
	lifespan -= delta
	if lifespan <= 0:
		queue_free()
	
	var prevPos = position
	if(active && hitBody == null && hitPoint == null):
		position += velocity * delta
	var travelled = (position - startPos).length()
	
	if(active):
		if(travelled >= bulletRange - 0.5):
			position = startPos + (position - startPos).normalized() * (bulletRange - 0.5)
			if(abs(position - prevPos).length() < 0.01):
				stop()
		travelled = (position - startPos).length()
		trailEnd = min(travelled, trailLength)
	else:
		trailLength -= muzzle_velocity * delta
		trailLength = max(0, trailLength)
		trailEnd = min(travelled, trailLength)
	
	if(bulletTrail != null):
		trailPoints = [Vector3.ZERO, Vector3(0, 0, -trailEnd)]
		bulletTrail.updateTrail(trailPoints)

func _physics_process(_delta):
	if(active):
		if(hitBody == null && hitPoint == null):
			#if raycast is intercepted within range, move to hitPoint next frame
			if(raycast.is_colliding() && (raycast.get_collision_point() - startPos).length() <= bulletRange - 0.5):
				hitBody = raycast.get_collider()
				var canHit = true
				if(hitBody == null):
					canHit = false
				if(hitBody.has_method("damage_taken")):
					canHit = hitBody.damage_taken(0, from, critHit, self)
				if(!canHit):
					hitBody = null
				else: #hits only if object doesn't have damage_taken or damage_taken returns true. otherwise passes through
					if(source == player):
						player.extraSounds.stream = hitSound
						player.extraSounds.play()
					hitPoint = raycast.get_collision_point() + velocity.normalized() * bulletStopExtend
		elif(hitPoint != null): #if hitPoint was set last frame, move to hitPoint
			position = hitPoint
			hitPoint = null
		elif(hitBody != null): #if hitBody was set 2 frames ago, hurt the body
			hit(hitBody)

func hit(body):
	if(hitBody.has_method("damage_taken")):
#		var bodyParent = body.get_parent()
		body.damage_taken(damage, from, critHit, self)
#		if(!("hitFlash" in body)):
#			var bodyParent = body.get_parent()
#			if("hitFlash" in bodyParent):
#				bodyParent.hitFlash.set_shader_parameter("color", trailColor)
#		else:
#			body.hitFlash.set_shader_parameter("color", trailColor)
	var wr = weakref(source) #used to see if source has been queue_free()'d or not
	if(wr.get_ref() && source.has_method("healFromBullet")):
		source.healFromBullet(damage)
	stop()

func stop():
	active = false
	get_node(NodePath("./MeshInstance3D")).visible = false
