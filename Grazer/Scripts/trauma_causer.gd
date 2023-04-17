extends Camera3D


# Called when the node enters the scene tree for the first time.
func cause_trauma():
	if $camera.has_method("add_trauma"):
		$camera.add_trauma(trauma)
