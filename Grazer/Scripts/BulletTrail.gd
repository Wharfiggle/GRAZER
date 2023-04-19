#Elijah Southman
extends ImmediateMesh

var mesh
var origColor

func prepareForColorChange(inMesh:MeshInstance3D):
	mesh = inMesh
	origColor = mesh.get_material_override().emission

func setColor(color:Color):
	mesh.get_material_override().albedo_color = color

func resetColor():
	mesh.get_material_override().albedo_color = origColor

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
