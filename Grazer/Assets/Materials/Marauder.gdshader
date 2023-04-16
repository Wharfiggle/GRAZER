shader_type spatial;
render_mode unshaded;

uniform float ammount = 0.0;
uniform vec4 color : source_color = vec4( 1.0, 0.0, 0.0, 1.0 );

void fragment()
{
	ALBEDO = color.rgb;
	ALPHA = 0.0;
	ALPHA = ammount;
}
