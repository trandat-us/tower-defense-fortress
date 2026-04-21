shader_type spatial;

uniform vec4 color_gap: source_color = vec4(0.0, 0.561, 0.0, 0.349);
uniform vec4 color_stripe: source_color = vec4(0.0, 0.561, 0.0, 1.0);
uniform float divisions = 15.0; // increase for more stripe density
uniform float stripe_bias = 2.5; // 1.0 means no stripes; 2.0 means stripes and gaps are equal size
uniform float angle = 0.7854; // in radians

void fragment() {
	float w = cos(angle) * UV.x + sin(angle) * UV.y;
	if (floor(mod(w * divisions, stripe_bias)) < 0.0001) {
		ALBEDO = color_gap.rgb;
		ALPHA = color_gap.a;
	} else {
		ALBEDO = color_stripe.rgb;
		ALPHA = color_stripe.a;
	}
}