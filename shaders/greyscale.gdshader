shader_type canvas_item;

uniform bool active = true;
uniform float amount : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (active) {
		float grey = dot(color.rgb, vec3(0.299, 0.587, 0.114));
		color.rgb = mix(color.rgb, vec3(grey), amount);
	}
	COLOR = color;
}
