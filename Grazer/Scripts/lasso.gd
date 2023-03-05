extends CharacterBody3D

var lasso: MeshInstance3D
var target
var lassoSpeed: float = 5.0
var lassoRange: float = 5.0
var lassoHead: Vector3

func _ready():
	#lasso = $MeshInstance3D
	lasso.visible = false

func _process(delta: float):
	if target and target.is_visible_in_tree():
		lasso.visible = true
		var distance = (target.global_transform.origin - global_transform.origin).length()
		if distance <= lassoRange:
			lassoHead = (target.global_transform.origin - global_transform.origin).normalized()
			set_velocity(lassoHead * lassoSpeed)
			move_and_slide()
		else:
			target = null
			lasso.visible = false

func throw_lasso(target, missRange: float = 2.0):
	var distance = (target.global_transform.origin - global_transform.origin).length()
	if distance <= lassoRange:
		var missDistance = randf() * missRange
		if randf() > 0.5:
			missDistance *= -1
		var missOffset = lassoHead * missDistance
		self.target = target.global_transform.origin + missOffset
	else:
		self.target = null
		lasso.visible = false
