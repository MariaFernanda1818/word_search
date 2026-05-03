shader_type canvas_item;

uniform vec4 sky_color : source_color = vec4(0.08, 0.22, 0.18, 1.0);
uniform vec4 forest_color : source_color = vec4(0.05, 0.35, 0.16, 1.0);
uniform vec4 leaf_color : source_color = vec4(0.32, 0.85, 0.28, 1.0);
uniform vec4 light_color : source_color = vec4(0.75, 1.0, 0.45, 1.0);

uniform float wind_speed = 0.55;
uniform float leaf_density = 24.0;
uniform float glow_strength = 0.18;

float random(vec2 st) {
	return fract(sin(dot(st.xy, vec2(41.231, 93.117))) * 12458.5453);
}

void fragment() {
	vec2 uv = UV;

	vec3 color = mix(sky_color.rgb, forest_color.rgb, uv.y);

	vec2 moving_uv = uv;
	moving_uv.x += sin(uv.y * 8.0 + TIME * wind_speed) * 0.035;
	moving_uv.y += TIME * 0.035;

	vec2 cell = floor(moving_uv * leaf_density);
	vec2 local = fract(moving_uv * leaf_density);

	float rnd = random(cell);
	float leaf_shape = distance(local, vec2(0.5, 0.5));
	float leaf = smoothstep(0.32, 0.0, leaf_shape) * step(0.68, rnd);

	float sway = 0.5 + 0.5 * sin(TIME * 1.4 + rnd * 6.28);
	color += leaf_color.rgb * leaf * (0.18 + sway * 0.12);

	float sun_ray = smoothstep(0.55, 0.0, distance(uv, vec2(0.8, 0.15)));
	color += light_color.rgb * sun_ray * glow_strength;

	float vignette = distance(uv, vec2(0.5));
	color *= smoothstep(0.95, 0.25, vignette);

	COLOR = vec4(color, 1.0);
}