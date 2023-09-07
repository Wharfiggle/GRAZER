shader_type spatial;
render_mode unshaded;

uniform vec3 camCenter = vec3(0, 0, 0);
uniform float fadeMod = 1.0;
uniform float fadeDist = 5.0;

//WORLD_MATRIX rename to MODEL_MATRIX
//WORLD_NORMAL_MATRIX rename to MODEL_NORMAL_MATRIX
//CAMERA_MATRIX rename to INV_VIEW_MATRIX
//INV_CAMERA_MATRIX rename to VIEW_MATRIX

void fragment()
{
	vec3 wrldVert = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float dist = length((camCenter - wrldVert));
	ALPHA = fadeMod / max(0.01, dist - fadeDist);
}
