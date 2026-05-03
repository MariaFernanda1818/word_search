shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.10, 0.13, 0.20, 1.0);
uniform vec4 border_color : source_color = vec4(0.35, 0.55, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.20, 0.45, 1.0, 1.0);
uniform vec4 accent_color : source_color = vec4(0.70, 0.85, 1.0, 1.0);

uniform float glow_strength = 0.30;
uniform float pulse_speed = 1.0;
uniform float pattern_strength = 0.12;
uniform float border_size = 0.035;

void fragment() {
	vec2 uv = UV;

	float border_x = min(uv.x, 1.0 - uv.x);
	float border_y = min(uv.y, 1.0 - uv.y);
	float border = min(border_x, border_y);

	float border_mask = smoothstep(border_size, 0.0, border);
	float inner_border = smoothstep(border_size * 2.4, border_size, border);

	float pulse = 0.70 + 0.30 * sin(TIME * pulse_speed);

	float diagonal_pattern = sin((uv.x + uv.y + TIME * 0.18) * 26.0) * 0.5 + 0.5;
	diagonal_pattern = smoothstep(0.72, 1.0, diagonal_pattern);

	float soft_light = 1.0 - distance(uv, vec2(0.5, 0.35));
	soft_light = smoothstep(0.25, 0.95, soft_light);

	vec3 color = base_color.rgb;

	color += accent_color.rgb * diagonal_pattern * pattern_strength;
	color += glow_color.rgb * soft_light * glow_strength * 0.35;
	color += glow_color.rgb * inner_border * glow_strength * pulse;
	color = mix(color, border_color.rgb, border_mask * 0.85);

	COLOR = vec4(color, 1.0);
}