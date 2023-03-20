extends Area3D

signal exploded
@export var muzzle_velocity = 150
@export var lifespan = 8
var velocity = Vector3.ZERO
@export var damage = 2
var from = ""
var active = true

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

func _on_body_entered(body):
	if(active):
		#emit_signal("exploded", transform.origin)
		var enemies = self.get_overlapping_bodies()
		var despawn = true
		for enemy in enemies:
			if enemy.has_method("damage_taken"):
				despawn = enemy.damage_taken(damage, from)
		if(despawn):
			get_node(NodePath("CollisionShape3D")).disabled = true
			get_node(NodePath("MeshInstance3D")).visible = false
			get_node(NodePath("Smoke/Particles")).emitting = false
			active = false
