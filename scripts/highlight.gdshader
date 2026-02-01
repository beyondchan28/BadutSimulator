shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;

uniform vec4 color : source_color = vec4(0.3, 0.9, 1.0, 0.7);
uniform float edge_softness : hint_range(0.01, 0.5) = 0.3;
uniform float pulse_speed = 2.0;
uniform float pulse_strength = 0.25;

void fragment() {
	float dist = distance(UV, vec2(0.5));
	float edge = smoothstep(0.5, 0.5 - edge_softness, dist);

	float pulse = sin(TIME * pulse_speed) * pulse_strength + 1.0;

	ALBEDO = color.rgb * pulse;
	ALPHA = edge * color.a;
}
