shader_type canvas_item;

uniform vec3 base_color: source_color = vec3(1.0);
uniform vec3 max_color: source_color = vec3(1.0);
uniform float fill = 0.5;

void fragment() {
	vec2 rounded_uv = floor(193.0 * UV) / 193.0;
	float y_pos = ((rounded_uv.y * 2.0 - 1.0) * 1.025 + 1.0) / 2.0;
	float mask = texture(TEXTURE, UV).a;
	vec3 color = fill >= 0.999 ? max_color : base_color;
	if (color != max_color && (abs(y_pos + fill - 1.0) * 193.0 < 2.05))
		color = vec3(1.0);
	COLOR = vec4(color, mask) * vec4(vec3(1.0), step(1.0 - fill, y_pos));
}
