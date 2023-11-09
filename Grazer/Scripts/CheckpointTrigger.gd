#Elijah Southman

extends Area3D

var triggered = false
@export var minimumCows = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var debugMesh = get_child(0)
	debugMesh.queue_free()

func _on_body_entered(body):
	if(body.is_in_group('Player') && !triggered):
		triggered = true
		body.checkpoint = position
		body.checkpointCowAmmount = body.herd.getNumCows()
		if(body.checkpointCowAmmount < minimumCows):
			body.checkpointCowAmmount = minimumCows
		body.checkpointElixirs = body.inventory
		body.checkpointUpgrades = body.gunStats
