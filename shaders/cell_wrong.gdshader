shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.65, 0.05, 0.08, 1.0);
uniform vec4 glow_color : source_color = vec4(1.0, 0.35, 0.38, 1.0);
uniform float glow_strength = 0.90;
uniform float pulse_speed = 4.0;

void fragment() {
	vec2 uv = UV;

	// Pequeña distorsión visual tipo alerta/error
	float shake = sin(TIME * 30.0) * 0.003;
	uv.x += shake;

	vec4 original = texture(TEXTURE, uv) * COLOR;

	float border_x = min(UV.x, 1.0 - UV.x);
	float border_y = min(UV.y, 1.0 - UV.y);
	float border = min(border_x, border_y);

	float edge = smoothstep(0.24, 0.0, border);
	float pulse = 0.55 + 0.45 * sin(TIME * pulse_speed);

	float warning_lines = sin((UV.y * 35.0) + TIME * 5.0) * 0.5 + 0.5;
	warning_lines = smoothstep(0.65, 1.0, warning_lines);

	vec3 color = base_color.rgb;
	color += glow_color.rgb * edge * glow_strength * pulse;
	color += glow_color.rgb * warning_lines * 0.14;

	float brightness = max(max(original.r, original.g), original.b);
	float letter_mask = smoothstep(0.45, 0.95, brightness);

	vec3 letter_color = mix(original.rgb, vec3(1.0), 0.30);

	color = mix(color, letter_color, letter_mask);

	COLOR = vec4(color, original.a);
}