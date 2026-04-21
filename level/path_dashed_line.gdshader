shader_type spatial;
render_mode unshaded;

uniform vec3 color: source_color = vec3(1.0, 1.0, 1.0);
uniform float color_correction: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float dash_length = 0.04;
uniform float gap_length = 0.02;
uniform float speed = 0.09;
uniform float reveal_progress : hint_range(0.0, 1.0) = 0.0;
uniform float shader_time = 0;

void fragment() {
	if (color_correction < 0.0001) {
		discard;
	}
	
	float pattern_len = dash_length + gap_length;
	
	float pos = UV.y;
	
	if (pos > reveal_progress) {
		discard;
	}
	
	pos -= shader_time * speed;
	ALBEDO = color;
	ALPHA = color_correction;
	
	if (mod(pos, pattern_len) > dash_length) {
		discard;
	}
}