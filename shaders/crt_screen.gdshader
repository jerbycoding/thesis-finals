shader_type spatial;

uniform sampler2D screen_texture : source_color;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.2;
uniform float screen_flicker : hint_range(0.0, 0.1) = 0.01;
uniform float curvature : hint_range(0.0, 1.0) = 0.1;

void fragment() {
	vec2 uv = UV;
	
	// Curvature
	vec2 centered_uv = uv * 2.0 - 1.0;
	vec2 offset = centered_uv.yx / vec2(8.0, 8.0);
	uv = uv + centered_uv * offset * offset * curvature;
	
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		ALBEDO = vec3(0.0);
	} else {
		vec4 text = texture(screen_texture, uv);
		
		// Scanlines
		float s = sin(uv.y * 400.0 * 3.1415);
		s = (s * 0.5 + 0.5) * 0.9 + 0.1;
		text.rgb *= mix(1.0, s, scanline_intensity);
		
		// Flicker
		float flicker = 1.0 + (sin(TIME * 50.0) * screen_flicker);
		text.rgb *= flicker;
		
		ALBEDO = text.rgb;
		EMISSION = text.rgb * 0.5;
	}
}
