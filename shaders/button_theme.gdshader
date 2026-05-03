shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.12, 0.20, 0.85, 1.0);
uniform vec4 border_color : source_color = vec4(0.45, 0.65, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.25, 0.45, 1.0, 1.0);
uniform vec4 shine_color : source_color = vec4(0.85, 0.95, 1.0, 1.0);

uniform float glow_strength = 0.24;
uniform float pulse_speed = 0.85;
uniform float shine_strength = 0.08;
uniform float border_size = 0.055;

void fragment() {
	vec2 uv = UV;

	float border_x = min(uv.x, 1.0 - uv.x);
	float border_y = min(uv.y, 1.0 - uv.y);
	float border = min(border_x, border_y);

	float border_mask = smoothstep(border_size, 0.0, border);
	float inner_glow = smoothstep(border_size * 3.0, border_size, border);

	float pulse = 0.75 + 0.25 * sin(TIME * pulse_speed);

	float shine = sin((uv.x - uv.y + TIME * 0.45) * 8.0) * 0.5 + 0.5;
	shine = smoothstep(0.88, 1.0, shine);

	float center_light = 1.0 - distance(uv, vec2(0.5));
	center_light = smoothstep(0.25, 0.9, center_light);

	vec3 color = base_color.rgb;
	color += glow_color.rgb * inner_glow * glow_strength * pulse;
	color += shine_color.rgb * shine * shine_strength;
	color += glow_color.rgb * center_light * glow_strength * 0.10;

	color = mix(color, border_color.rgb, border_mask * 0.70);

	COLOR = vec4(color, 1.0);
}