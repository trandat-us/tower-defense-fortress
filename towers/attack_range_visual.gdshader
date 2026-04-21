shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_add;

group_uniforms ring_visual;
uniform float alpha: hint_range(0.0, 1.0, 0.001) = 1.0;
uniform vec4  ring_color: source_color = vec4(1.0, 1.0, 1.0, 0.6);
uniform float ring_width: hint_range(0.001, 0.05, 0.001) = 0.01;

group_uniforms ring_radius;
uniform float outer_radius: hint_range(0.0, 1.0, 0.001) = 1.0;
uniform float inner_radius: hint_range(0.0, 1.0, 0.001) = 0.0; 

group_uniforms edge_softness;
uniform float outer_softness: hint_range(0.001, 0.1, 0.001) = 0.001;
uniform float inner_softness: hint_range(0.001, 0.1, 0.001) = 0.03;

float make_small_ring(float dist, float radius) {
	if(radius < 0.0001) return 0.0;
	
	float inner_edge = radius;
	float outer_edge = inner_edge + ring_width;
	return smoothstep(inner_edge, inner_edge + outer_softness, dist) * smoothstep(outer_edge + inner_softness, outer_edge, dist);
}

float make_big_ring(float dist, float radius) {
	float outer_edge = radius;
	float inner_edge = radius - ring_width;
	return smoothstep(inner_edge - inner_softness, inner_edge, dist) * smoothstep(outer_edge, outer_edge - outer_softness, dist);
}

void fragment() {
	vec2  uv   = 2.0 * UV - 1.0;
	float dist = length(uv);
	
	float ring = make_big_ring(dist, outer_radius) + make_small_ring(dist, inner_radius);
	
	ring = clamp(ring, 0.0, 1.0);
	
	ALBEDO = ring_color.rgb;
	ALPHA  = ring * ring_color.a * alpha;
}