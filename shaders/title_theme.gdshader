shader_type canvas_item;

uniform vec4 text_color : source_color = vec4(0.65, 0.85, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.20, 0.45, 1.0, 1.0);
uniform vec4 shadow_color : source_color = vec4(0.02, 0.04, 0.08, 1.0);

uniform float glow_strength = 0.55;
uniform float pulse_speed = 1.2;
uniform float distortion_strength = 0.002;
uniform float scanline_strength = 0.08;
uniform float wave_strength = 0.002;

void fragment() {
	vec2 uv = UV;

	uv.x += sin((UV.y * 35.0) + TIME * pulse_speed) * distortion_strength;
	uv.y += sin((UV.x * 20.0) + TIME * pulse_speed * 0.7) * wave_strength;

	vec4 original = texture(TEXTURE, uv) * COLOR;

	float alpha = original.a;

	float pulse = 0.70 + 0.30 * sin(TIME * pulse_speed);

	float scanline = sin((UV.y * 80.0) + TIME * 2.0) * 0.5 + 0.5;

	vec2 shadow_offset = vec2(0.006, 0.006);
	float shadow_alpha = texture(TEXTURE, UV - shadow_offset).a * 0.50;

	vec3 color = text_color.rgb;
	color += glow_color.rgb * glow_strength * pulse;
	color += glow_color.rgb * scanline * scanline_strength;

	vec3 final_color = mix(shadow_color.rgb, color, alpha);
	float final_alpha = max(alpha, shadow_alpha);

	COLOR = vec4(final_color, final_alpha);
}