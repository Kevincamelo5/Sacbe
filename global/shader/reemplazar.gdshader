shader_type canvas_item;

uniform vec4 target_color : source_color = vec4(1.);

void fragment() {
	COLOR = target_color;
}
