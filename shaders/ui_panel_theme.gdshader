shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.04, 0.07, 0.12, 0.95);
uniform vec4 border_color : source_color = vec4(0.25, 0.55, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.1, 0.3, 1.0, 1.0);
uniform vec4 accent_color : source_color = vec4(0.6, 0.8, 1.0, 1.0);

uniform float glow_strength = 0.30;
uniform float pulse_speed = 1.0;
uniform float pattern_strength = 0.10;
uniform float shine_strength = 0.08;

void fragment() {
	vec2 uv = UV;

	float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);

	float border_x = smoothstep(0.0, 0.025, uv.x) *
		smoothstep(0.0, 0.025, 1.0 - uv.x);

	float border_y = smoothstep(0.0, 0.025, uv.y) *
		smoothstep(0.0, 0.025, 1.0 - uv.y);

	float inner_mask = border_x * border_y;
	float border_mask = 1.0 - inner_mask;

	float diagonal_pattern = sin((uv.x + uv.y + TIME * 0.08) * 28.0);
	diagonal_pattern = smoothstep(0.72, 1.0, diagonal_pattern);

	float shine = smoothstep(0.0, 0.18, uv.x + uv.y - fract(TIME * 0.18) * 2.0);
	shine *= smoothstep(0.42, 0.0, uv.x + uv.y - fract(TIME * 0.18) * 2.0);

	vec4 color = base_color;

	color.rgb += accent_color.rgb * diagonal_pattern * pattern_strength;
	color.rgb += accent_color.rgb * shine * shine_strength;
	color.rgb += glow_color.rgb * border_mask * (glow_strength + pulse * 0.18);
	color.rgb += border_color.rgb * border_mask * 0.85;

	color.a = base_color.a;

	COLOR = color;
}