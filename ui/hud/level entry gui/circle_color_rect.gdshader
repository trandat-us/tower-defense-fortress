shader_type canvas_item;

void fragment() {
	float circle = step(distance(UV, vec2(0.5)), 0.5);
	float inner_circle = step(distance(UV, vec2(0.5)), 0.48);
	COLOR.a *= (circle - inner_circle);
}
