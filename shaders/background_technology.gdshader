shader_type canvas_item;

uniform vec4 background_color : source_color = vec4(0.04, 0.06, 0.10, 1.0);
uniform vec4 grid_color : source_color = vec4(0.10, 0.45, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.00, 0.85, 1.0, 1.0);

uniform float grid_scale = 32.0;
uniform float line_width = 0.035;
uniform float speed = 0.35;
uniform float glow_strength = 0.35;

void fragment() {
	vec2 uv = UV;
	vec2 moving_uv = uv;

	moving_uv.y += TIME * speed * 0.08;
	moving_uv.x += sin(TIME * 0.4) * 0.02;

	vec2 grid = fract(moving_uv * grid_scale);

	float line_x = smoothstep(line_width, 0.0, min(grid.x, 1.0 - grid.x));
	float line_y = smoothstep(line_width, 0.0, min(grid.y, 1.0 - grid.y));
	float grid_lines = max(line_x, line_y);

	float pulse = 0.5 + 0.5 * sin(TIME * 2.0);
	float circuit = sin((uv.x + uv.y + TIME * 0.25) * 35.0) * 0.5 + 0.5;
	circuit = smoothstep(0.82, 1.0, circuit);

	vec3 color = background_color.rgb;
	color += grid_color.rgb * grid_lines * 0.22;
	color += glow_color.rgb * circuit * glow_strength * pulse;

	COLOR = vec4(color, 1.0);
}