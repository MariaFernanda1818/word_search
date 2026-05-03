shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.05, 0.55, 0.22, 1.0);
uniform vec4 glow_color : source_color = vec4(0.55, 1.0, 0.65, 1.0);
uniform float glow_strength = 0.80;
uniform float pulse_speed = 1.2;

void fragment() {
	vec4 original = texture(TEXTURE, UV) * COLOR;

	float border_x = min(UV.x, 1.0 - UV.x);
	float border_y = min(UV.y, 1.0 - UV.y);
	float border = min(border_x, border_y);

	float edge = smoothstep(0.25, 0.0, border);
	float pulse = 0.75 + 0.25 * sin(TIME * pulse_speed);

	float diagonal_wave = sin((UV.x + UV.y + TIME * 0.45) * 16.0) * 0.5 + 0.5;
	diagonal_wave = smoothstep(0.65, 1.0, diagonal_wave);

	vec3 color = base_color.rgb;
	color += glow_color.rgb * edge * glow_strength * pulse;
	color += glow_color.rgb * diagonal_wave * 0.18;

	float brightness = max(max(original.r, original.g), original.b);
	float letter_mask = smoothstep(0.45, 0.95, brightness);

	vec3 letter_color = mix(original.rgb, vec3(1.0), 0.35);

	color = mix(color, letter_color, letter_mask);

	COLOR = vec4(color, original.a);
}