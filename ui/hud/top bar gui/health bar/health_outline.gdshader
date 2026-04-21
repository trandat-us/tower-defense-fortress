shader_type canvas_item;

uniform vec4 modulate: source_color = vec4(1.0);
uniform vec4 line_color: source_color = vec4(1.0);
uniform float line_thickness = 7.0;

void fragment() {
	if (line_thickness > 0.0) {
		vec4 color = texture(TEXTURE, UV);
		color = mix(color, modulate, color.a);
		vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
		float outline = color.a;
		
		for(float x = -1.0; x <= 1.0; x++) {
			for(float y = -1.0; y <= 1.0; y++) {
				vec2 offset = vec2(x, y) * size;
				outline += texture(TEXTURE, UV + offset).a;
			}
		}
		
		outline = min(outline, 1.0);
		COLOR = mix(color, line_color, outline - color.a);
	}
}
