shader_type canvas_item;

uniform float scanline_count : hint_range(0, 1800) = 300.0;
uniform float scanline_opacity : hint_range(0, 1) = 0.1;
uniform float vignette_opacity : hint_range(0, 1) = 0.5;
uniform float aberration : hint_range(0, 0.1) = 0.002;
uniform float brightness : hint_range(0, 2) = 1.2;

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Chromatic Aberration
    vec4 color;
    color.r = texture(SCREEN_TEXTURE, uv + vec2(aberration, 0.0)).r;
    color.g = texture(SCREEN_TEXTURE, uv).g;
    color.b = texture(SCREEN_TEXTURE, uv - vec2(aberration, 0.0)).b;
    color.a = 1.0;
    
    // Scanlines
    float scanline = sin(uv.y * scanline_count * PI * 2.0);
    scanline = (scanline + 1.0) * 0.5;
    scanline = mix(1.0, scanline, scanline_opacity);
    color.rgb *= scanline;
    
    // Vignette
    float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
    vignette = pow(vignette * 15.0, 0.5);
    vignette = mix(1.0, vignette, vignette_opacity);
    color.rgb *= vignette;
    
    // Screen Brightness
    color.rgb *= brightness;
    
    COLOR = color;
}
