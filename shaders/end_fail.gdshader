shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.24, 0.05, 0.07, 1.0);
uniform vec4 border_color : source_color = vec4(1.0, 0.20, 0.30, 1.0);
uniform vec4 glow_color : source_color = vec4(1.0, 0.12, 0.18, 1.0);
uniform vec4 warning_color : source_color = vec4(1.0, 0.45, 0.35, 1.0);

uniform float glow_strength = 0.42;
uniform float pulse_speed = 2.2;
uniform float warning_strength = 0.16;
uniform float border_size = 0.035;

void fragment() {
	vec2 uv = UV;

	float shake = sin(TIME * 22.0) * 0.0018;
	uv.x += shake;

	float border_x = min(uv.x, 1.0 - uv.x);
	float border_y = min(uv.y, 1.0 - uv.y);
	float border = min(border_x, border_y);

	float border_mask = smoothstep(border_size, 0.0, border);
	float inner_glow = smoothstep(border_size * 4.0, border_size, border);

	float pulse = 0.55 + 0.45 * sin(TIME * pulse_speed);

	float warning_lines = sin((uv.y * 42.0) + TIME * 4.0) * 0.5 + 0.5;
	warning_lines = smoothstep(0.70, 1.0, warning_lines);

	float center_dark = distance(uv, vec2(0.5, 0.5));
	center_dark = smoothstep(0.0, 0.85, center_dark);

	vec3 color = base_color.rgb;

	color += warning_color.rgb * warning_lines * warning_strength;
	color += glow_color.rgb * inner_glow * glow_strength * pulse;
	color += glow_color.rgb * center_dark * 0.06;

	color = mix(color, border_color.rgb, border_mask * 0.92);

	COLOR = vec4(color, 1.0);
}