shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.15;
uniform float aberration_amount : hint_range(0.0, 0.02) = 0.002;
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.8;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Apply Glitch Displacement
    if (glitch_intensity > 0.01) {
        float slice_y = floor(uv.y * 30.0) / 30.0;
        float noise = rand(vec2(slice_y, TIME));
        if (noise > (1.0 - glitch_intensity)) {
            uv.x += (rand(vec2(slice_y, TIME * 2.0)) - 0.5) * glitch_intensity * 0.1;
        }
    }

    // Chromatic Aberration
    float r = texture(SCREEN_TEXTURE, uv + vec2(aberration_amount + glitch_intensity * 0.02, 0.0)).r;
    float g = texture(SCREEN_TEXTURE, uv).g;
    float b = texture(SCREEN_TEXTURE, uv - vec2(aberration_amount + glitch_intensity * 0.02, 0.0)).b;
    vec4 col = vec4(r, g, b, 1.0);

    // Scanlines
    float scanline = sin(uv.y * 800.0) * 0.5 + 0.5;
    col.rgb *= 1.0 - (scanline_intensity * (1.0 - scanline));

    // Vignette
    vec2 vig_uv = uv * (1.0 - uv.yx);
    float vignette = pow(vig_uv.x * vig_uv.y * 15.0, vignette_strength);
    col.rgb *= vignette;

    // Subtle Green Pulse
    float pulse = (sin(TIME * pulse_speed) * 0.02) + 0.98;
    col.rgb *= vec3(pulse * 0.9, pulse, pulse * 0.9);

    COLOR = col;
}
