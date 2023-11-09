#Elijah Southman

extends Node3D

var enemies = []
var parent

# Called when the node enters the scene tree for the first time.
func _ready():
	parent = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var toRemove = []
	for i in enemies:
		var wr = weakref(i) #used to see if source has been queue_free()'d or not
		if(!wr.get_ref()):
			toRemove.append(i)
			parent.use()
			print("enemy died")
	for i in toRemove:
		enemies.erase(i)

func passEnemy(enemy):
	enemies.append(enemy)
	print("enemy passed")
