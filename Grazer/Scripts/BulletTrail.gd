#Elijah Southman
extends ImmediateMesh

func updateTrail(points:Array):
	clear_surfaces()
	surface_begin(PRIMITIVE_LINES, null)
	for i in points.size():
		if i + 1 < points.size():
			var a = points[i]
			var b = points[i + 1]
			surface_add_vertex(a)
			surface_add_vertex(b)
	surface_end()
