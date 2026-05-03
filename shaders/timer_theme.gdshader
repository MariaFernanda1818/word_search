shader_type canvas_item;

uniform vec4 text_color : source_color = vec4(0.38, 0.65, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.15, 0.45, 1.0, 1.0);
uniform vec4 shadow_color : source_color = vec4(0.02, 0.04, 0.08, 1.0);

uniform float glow_strength = 0.55;
uniform float pulse_speed = 1.4;
uniform float distortion_strength = 0.002;
uniform float scanline_strength = 0.10;

void fragment() {
	vec2 uv = UV;

	// Pequeña deformación para cambiar la "forma" visual del texto
	uv.x += sin((uv.y * 35.0) + TIME * pulse_speed) * distortion_strength;

	vec4 original = texture(TEXTURE, uv) * COLOR;

	float alpha = original.a;

	// Pulso suave
	float pulse = 0.70 + 0.30 * sin(TIME * pulse_speed);

	// Líneas internas tipo digital / tiza / natural según colores
	float scanline = sin((UV.y * 70.0) + TIME * 2.0) * 0.5 + 0.5;

	vec3 color = text_color.rgb;

	color += glow_color.rgb * glow_strength * pulse;
	color += glow_color.rgb * scanline * scanline_strength;

	// Sombra suave alrededor del texto
	vec2 offset = vec2(0.006, 0.006);
	float shadow_alpha = texture(TEXTURE, UV - offset).a * 0.45;

	vec3 final_color = mix(shadow_color.rgb, color, alpha);

	float final_alpha = max(alpha, shadow_alpha);

	COLOR = vec4(final_color, final_alpha);
}