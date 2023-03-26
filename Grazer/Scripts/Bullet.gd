extends Area3D

signal exploded
@export var muzzle_velocity = 150
@export var lifespan = 8
var velocity = Vector3.ZERO
var damage
var from = ""
var source
var active = true
var smoke = preload("res://Prefabs/Smoke.tscn")
var waitForSmoke = 0
var hitBody = null
@onready var raycast = get_node(NodePath("./RayCast3D"))

# Called when the node enters the scene tree for the first time.
#func _ready():
	#self.connect("area_entered",Callable(self,"_on_body_enter"))

func _process(delta):
	if(velocity == Vector3.ZERO):
		velocity = Vector3(sin(rotation.y) * muzzle_velocity, 0, cos(rotation.y) * muzzle_velocity)
	if(active && hitBody == null):
		position += velocity * delta
	
	lifespan -= delta
	if lifespan <= 0:
		queue_free()

func shoot(inSource:Node3D, inFrom:String, inPosition:Vector3, inRotation:Vector3, inDamage:float):
	source = inSource
	from = inFrom
	source.get_parent().add_child(self)
	rotation = inRotation
	global_position = inPosition
	damage = inDamage

func _physics_process(delta):
	if(waitForSmoke == 0):
		var smokeInstance = smoke.instantiate()
		smokeInstance.rotation = Vector3.ZERO
		add_child(smokeInstance)
		smokeInstance.global_position = global_position
		waitForSmoke += 1
	
	if(active):
		if(hitBody != null):
			hit(hitBody)
		if(raycast.is_colliding()):
			hitBody = raycast.get_collider()
			var canHit = true
			if(hitBody.has_method("damage_taken")):
				canHit = hitBody.damage_taken(0, from)
			if(!canHit):
				hitBody = null
			else:
				position = raycast.get_collision_point()

func hit(body):
	if(hitBody.has_method("damage_taken")):
		body.damage_taken(damage, from)
	get_node(NodePath("./MeshInstance3D")).visible = false
	var particles = get_node(NodePath("./Smoke")).get_children()
	for i in particles:
		i.emitting = false
	active = false
