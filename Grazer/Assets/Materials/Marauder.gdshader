shader_type spatial;
render_mode unshaded;
render_mode depth_test_disabled;

uniform float ammount = 0.0;
uniform vec4 color : source_color = vec4( 1.0, 0.0, 0.0, 1.0 );

void fragment()
{
	ALBEDO = color.rgb;
	ALPHA = 0.0;
	ALPHA = ammount;
}
