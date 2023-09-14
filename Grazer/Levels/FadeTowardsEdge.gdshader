shader_type spatial;
render_mode unshaded;
render_mode ambient_light_disabled;
render_mode shadows_disabled;

uniform vec3 camCenter = vec3(0, 0, 0);
uniform vec3 color = vec3(1, 1, 1);
uniform float fadeMod = 1.0;
uniform float fadeDist = 5.0;
uniform float maxOpacity = 1.0;

//WORLD_MATRIX rename to MODEL_MATRIX
//WORLD_NORMAL_MATRIX rename to MODEL_NORMAL_MATRIX
//CAMERA_MATRIX rename to INV_VIEW_MATRIX
//INV_CAMERA_MATRIX rename to VIEW_MATRIX

void fragment()
{
	vec3 wrldVert = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float dist = length((camCenter - wrldVert));
	ALPHA = min(1.0, fadeMod / max(1.0, dist - fadeDist));
	ALPHA *= maxOpacity;
	ALBEDO = color;
}
