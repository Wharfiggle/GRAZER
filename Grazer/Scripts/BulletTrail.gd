#Elijah Southman
extends ImmediateMesh

var mesh
#var origColor
var isLineSight

func prepareForColorChange(inMesh:MeshInstance3D, lineSight:bool = false):
	isLineSight = lineSight
	mesh = inMesh
#	origColor = mesh.get_material_override().albedo_color

func setColor(color:Color):
	if(!isLineSight):
		mesh.get_material_override().albedo_color = color
	else:
		mesh.get_material_override().set_shader_parameter("color", color)

#func resetColor():
#	mesh.get_material_override().albedo_color = origColor

func updateCamCenter(camCenter:Vector3):
	if(isLineSight):
		mesh.get_material_override().set_shader_parameter("camCenter", camCenter)
		
func updateMaxOpacity(opacity:float):
	if(isLineSight):
		mesh.get_material_override().set_shader_parameter("maxOpacity", opacity)

func updateTrail(points:Array):
	clear_surfaces()
	surface_begin(PRIMITIVE_LINES, null)
#	if(isLineSight && points.size() > 0):
#		mesh.get_material_override().set_shader_parameter("camCenter", points[0])
	for i in points.size():
		if i + 1 < points.size():
			var a = points[i]
			var b = points[i + 1]
			surface_add_vertex(a)
			surface_add_vertex(b)
	surface_end()
