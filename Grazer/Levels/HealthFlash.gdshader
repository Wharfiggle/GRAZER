shader_type canvas_item;

uniform float intensity = 0.0;
uniform float opacity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 rgb = vec4(1.0, 0.0, 0.5, 1.0);
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

float vignette(vec2 uv)
{
	uv *= 1.0 - uv.xy;
	float vignette = uv.x * uv.y * 25.0;
	return pow(vignette, ((1.0 + intensity * sin(TIME * 2.0)) * intensity) * opacity);
}

void fragment()
{
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 text = texture(TEXTURE, UV);
	
	text.rgba *= rgb.rgba;
	text.rgba *= 1.0 - vignette(UV);
	
	COLOR = vec4(text.rgb * color.rgb, text.a);
}