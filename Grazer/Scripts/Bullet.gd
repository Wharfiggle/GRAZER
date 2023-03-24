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

# Called when the node enters the scene tree for the first time.
#func _ready():
	#self.connect("area_entered",Callable(self,"_on_body_enter"))

func _process(delta):
	if(velocity == Vector3.ZERO):
		velocity = Vector3(sin(rotation.y) * muzzle_velocity, 0, cos(rotation.y) * muzzle_velocity)
	if(active):
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
	var smokeInstance = smoke.instantiate()
	smokeInstance.rotation = Vector3.ZERO
	add_child(smokeInstance)
	smokeInstance.global_position = global_position
	damage = inDamage

#todo:
#add ray cast to see if the bullet will enter an object next frame,
#then next frame make bullet stop at intersection,
#then next frame make bulet despawn
func _on_body_entered(body):
	if(active):
		#emit_signal("exploded", transform.origin)
		#var enemies = self.get_overlapping_bodies()
		var despawn = true
		#for enemy in enemies:
		if body.has_method("damage_taken"):
			despawn = body.damage_taken(damage, from)
		
		if(despawn):
			get_node(NodePath("MeshInstance3D")).visible = false
			get_node(NodePath("Smoke/Particles")).emitting = false
			active = false
