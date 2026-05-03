shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.06, 0.22, 0.12, 1.0);
uniform vec4 border_color : source_color = vec4(0.20, 0.85, 0.40, 1.0);
uniform vec4 glow_color : source_color = vec4(0.45, 1.0, 0.62, 1.0);
uniform vec4 shine_color : source_color = vec4(0.85, 1.0, 0.75, 1.0);

uniform float glow_strength = 0.35;
uniform float pulse_speed = 1.15;
uniform float pattern_strength = 0.12;
uniform float border_size = 0.035;

void fragment() {
	vec2 uv = UV;

	float border_x = min(uv.x, 1.0 - uv.x);
	float border_y = min(uv.y, 1.0 - uv.y);
	float border = min(border_x, border_y);

	float border_mask = smoothstep(border_size, 0.0, border);
	float inner_glow = smoothstep(border_size * 4.0, border_size, border);

	float pulse = 0.70 + 0.30 * sin(TIME * pulse_speed);

	float diagonal = sin((uv.x + uv.y + TIME * 0.35) * 18.0) * 0.5 + 0.5;
	diagonal = smoothstep(0.72, 1.0, diagonal);

	float center_light = 1.0 - distance(uv, vec2(0.5, 0.45));
	center_light = smoothstep(0.25, 0.95, center_light);

	vec3 color = base_color.rgb;

	color += shine_color.rgb * diagonal * pattern_strength;
	color += glow_color.rgb * center_light * glow_strength * 0.45;
	color += glow_color.rgb * inner_glow * glow_strength * pulse;

	color = mix(color, border_color.rgb, border_mask * 0.90);

	COLOR = vec4(color, 1.0);
}