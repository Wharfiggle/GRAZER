extends Area

signal exploded
# Declare member variables

export var muzzle_velocity = 35

var lifespan = 10

var velocity = Vector3.ZERO

var damage = 2

onready var bullet = $CollisionShape

func _physics_process(delta):
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta
	
	lifespan -= delta
	
	if lifespan <= 0:
		queue_free()

	
	

func _on_Shell_body_entered():
	#emit_signal("exploded", transform.origin)
	var enemies = bullet.get_overlapping_bodies()
	
	for enemy in enemies:
		print("enemy found")
		if enemy.has_method("damage_taken"):
			enemy.damage_taken(damage)
	
	queue_free()
	print("tink")
# Called when the node enters the scene tree for the first time.
#func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
