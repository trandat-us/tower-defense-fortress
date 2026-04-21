shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount = 1.5;

void fragment() {
	vec4 result = textureLod(screen_texture, SCREEN_UV, blur_amount);
	COLOR = result;
}