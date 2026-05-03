shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.12, 0.35, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.65, 0.85, 1.0, 1.0);
uniform float glow_strength = 0.70;
uniform float pulse_speed = 2.2;

void fragment() {
	vec4 original = texture(TEXTURE, UV) * COLOR;

	float border_x = min(UV.x, 1.0 - UV.x);
	float border_y = min(UV.y, 1.0 - UV.y);
	float border = min(border_x, border_y);

	float edge = smoothstep(0.22, 0.0, border);
	float pulse = 0.65 + 0.35 * sin(TIME * pulse_speed);

	float center_light = 1.0 - distance(UV, vec2(0.5));
	center_light = smoothstep(0.25, 0.75, center_light);

	vec3 color = base_color.rgb;
	color += glow_color.rgb * edge * glow_strength * pulse;
	color += glow_color.rgb * center_light * 0.16 * pulse;

	float brightness = max(max(original.r, original.g), original.b);
	float letter_mask = smoothstep(0.45, 0.95, brightness);

	vec3 letter_color = mix(original.rgb, vec3(1.0), 0.45);

	color = mix(color, letter_color, letter_mask);

	COLOR = vec4(color, original.a);
}