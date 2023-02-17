shader_type canvas_item;
//orange
uniform vec4 color_1 = vec4(0.99, 0.71, 0.08, 1.0);
uniform vec4 color_2 = vec4(0.98, 0.64, 0.17, 1.0);
uniform vec4 color_3 = vec4(0.96, 0.53, 0.13, 1.0);
//redorange
uniform vec4 color_4 = vec4(0.84, 0.33, 0.15, 1.0);
uniform vec4 color_5 = vec4(0.74, 0.24, 0.15, 1.0);
uniform vec4 color_6 = vec4(0.63, 0.18, 0.15, 1.0);
uniform vec4 color_7 = vec4(0.47, 0.11, 0.16, 1.0);
uniform vec4 color_8 = vec4(0.26, 0.08, 0.17, 1.0);
uniform vec4 color_9 = vec4(0.13, 0.05, 0.13, 1.0);
//green
uniform vec4 color_10 = vec4(0.80, 0.75, 0.17, 1.0);
uniform vec4 color_11 = vec4(0.58, 0.59, 0.13, 1.0);
uniform vec4 color_12 = vec4(0.44, 0.47, 0.19, 1.0);
uniform vec4 color_13 = vec4(0.32, 0.32, 0.21, 1.0);
uniform vec4 color_14 = vec4(0.20, 0.20, 0.18, 1.0);
uniform vec4 color_15 = vec4(0.15, 0.15, 0.18, 1.0);
//red
uniform vec4 color_16 = vec4(0.55, 0.13, 0.09, 1.0);
uniform vec4 color_17 = vec4(0.49, 0.09, 0.09, 1.0);
uniform vec4 color_18 = vec4(0.42, 0.07, 0.09, 1.0);
uniform vec4 color_19 = vec4(0.31, 0.04, 0.09, 1.0);
uniform vec4 color_20 = vec4(0.17, 0.03, 0.11, 1.0);
uniform vec4 color_21 = vec4(0.09, 0.02, 0.07, 1.0);
//brown
uniform vec4 color_22 = vec4(0.53, 0.30, 0.11, 1.0);
uniform vec4 color_23 = vec4(0.38, 0.24, 0.08, 1.0);
uniform vec4 color_24 = vec4(0.29, 0.18, 0.11, 1.0);
uniform vec4 color_25 = vec4(0.21, 0.13, 0.13, 1.0);
uniform vec4 color_26 = vec4(0.13, 0.08, 0.11, 1.0);
uniform vec4 color_27 = vec4(0.10, 0.06, 0.11, 1.0);

void fragment()
{
	vec4 colors[27] = {color_1, color_2, color_3, color_4, 
	color_5, color_6, color_7, color_8, color_9, color_10, 
	color_11, color_12, color_13, color_14, color_15,
	color_16, color_17, color_18, color_19, color_20,
	color_21, color_22, color_23, color_24, color_25,
	color_26, color_27};
	//VV THIS IS TERRIBLE DON'T DO THIS VV
	/*vec4 colors[27] = {
		//orange
		vec4(0.99, 0.71, 0.08, 1.0),
		vec4(0.98, 0.64, 0.17, 1.0),
		vec4(0.96, 0.53, 0.13, 1.0),
		//redorange
		vec4(0.84, 0.33, 0.15, 1.0),
		vec4(0.74, 0.24, 0.15, 1.0),
		vec4(0.63, 0.18, 0.15, 1.0),
		vec4(0.47, 0.11, 0.16, 1.0),
		vec4(0.26, 0.08, 0.17, 1.0),
		vec4(0.13, 0.05, 0.13, 1.0),
		//green
		vec4(0.80, 0.75, 0.17, 1.0),
		vec4(0.58, 0.59, 0.13, 1.0),
		vec4(0.44, 0.47, 0.19, 1.0),
		vec4(0.32, 0.32, 0.21, 1.0),
		vec4(0.20, 0.20, 0.18, 1.0),
		vec4(0.15, 0.15, 0.18, 1.0),
		//red
		vec4(0.55, 0.13, 0.09, 1.0),
		vec4(0.49, 0.09, 0.09, 1.0),
		vec4(0.42, 0.07, 0.09, 1.0),
		vec4(0.31, 0.04, 0.09, 1.0),
		vec4(0.17, 0.03, 0.11, 1.0),
		vec4(0.09, 0.02, 0.07, 1.0),
		//brown
		vec4(0.53, 0.30, 0.11, 1.0),
		vec4(0.38, 0.24, 0.08, 1.0),
		vec4(0.29, 0.18, 0.11, 1.0),
		vec4(0.21, 0.13, 0.13, 1.0),
		vec4(0.13, 0.08, 0.11, 1.0),
		vec4(0.10, 0.06, 0.11, 1.0)
	};*/
	
	vec2 uv = SCREEN_UV;
	vec4 texColor = textureLod(SCREEN_TEXTURE, uv, 0.0);
	vec4 closestColor = colors[0];
	float closestDiff = 1000.0;
	for (int i = 1; i < colors.length(); i++)
	{
		float diff = distance(colors[i], texColor);
		if (diff < closestDiff)
		{
			closestDiff = diff;
			closestColor = colors[i];
		}
	}
	COLOR.rgba = closestColor;
}