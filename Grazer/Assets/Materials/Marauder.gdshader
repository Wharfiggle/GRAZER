shader_type spatial;
render_mode unshaded;

uniform bool active = false;
uniform vec4 color : source_color = vec4( 1.0, 0.0, 0.0, 1.0 );

void fragment()
{
	ALBEDO = color.rgb;
	ALPHA = 0.0;
	if(active)
		ALPHA = color.a;
}
