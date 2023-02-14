shader_type canvas_item;

uniform vec4 color_1 = vec4(0.88, 0.98, 0.89, 1.0);
uniform vec4 color_2 = vec4(0.2, 0.89, 0.35, 1.0);
uniform vec4 color_3 = vec4(0.19, 0.66, 0.37, 1.0);
uniform vec4 color_4 = vec4(0.07, 0.41, 0.21, 1.0);
uniform vec4 color_5 = vec4(0.26, 0.08, 0.17, 1.0);
uniform vec4 color_6 = vec4(0.13, 0.05, 0.13, 1.0);
uniform vec4 color_7 = vec4(0.99, 0.71, 0.01, 1.0);
uniform vec4 color_8 = vec4(0.74, 0.24, 0.15, 1.0);
uniform vec4 color_9 = vec4(0.47, 0.11, 0.16, 1.0);

uniform vec4 color_10 = vec4(0.19, 0.66, 0.37, 1.0);
uniform vec4 color_11 = vec4(0.19, 0.66, 0.37, 1.0);

void fragment() {

	vec4 colors[11] = {color_1, color_2, color_3, color_4, color_5, color_6, color_7, color_8, color_9, color_10, color_11};
	float min_diff = -1.0;
	vec4 min_color = vec4(0.0, 0.0, 0.0, 1.0);

	vec2 uv = SCREEN_UV;

	vec4 temp = textureLod(SCREEN_TEXTURE, uv, 0.0);

	min_diff = 1000.0;
	for (int i = 0; i < colors.length(); i++) {

		float curr_dist = distance(colors[i], temp);
		if (curr_dist < min_diff) {
			min_diff = curr_dist;
			min_color = colors[i];
		}
	}

	COLOR.rgb = min_color.rgb;
}