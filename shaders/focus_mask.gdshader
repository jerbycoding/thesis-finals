shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// Target position and size in normalized UV coordinates (0.0 to 1.0)
uniform vec2 target_uv_pos;
uniform vec2 target_uv_size;
uniform float dim_alpha : hint_range(0.0, 1.0) = 0.7;
uniform float softness : hint_range(0.0, 0.5) = 0.02;

uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.15;
uniform float aberration_amount : hint_range(0.0, 0.1) = 0.002;

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Calculate bounds in UV space
    vec2 half_size = target_uv_size * 0.5;
    vec2 center = target_uv_pos + half_size;
    
    // Standard Box SDF in UV space
    vec2 d = abs(uv - center) - half_size;
    float dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
    
    // Smooth mask (0 inside target, 1 outside)
    float mask = smoothstep(0.0, softness, dist);
    
    // Get underlying color
    vec4 scene_color = texture(screen_texture, uv);
    
    if (mask > 0.01) {
        // Apply Chromatic Aberration to the dimmed area
        float r = texture(screen_texture, uv + vec2(aberration_amount, 0.0)).r;
        float g = scene_color.g;
        float b = texture(screen_texture, uv - vec2(aberration_amount, 0.0)).b;
        scene_color = vec4(r, g, b, 1.0);
        
        // Apply Scanlines
        float scanline = sin(uv.y * 800.0) * scanline_intensity;
        scene_color.rgb -= scanline;
        
        // Apply Dimming
        scene_color.rgb = mix(scene_color.rgb, vec3(0.0, 0.0, 0.0), dim_alpha);
    }
    
    COLOR = vec4(scene_color.rgb, 1.0);
    
    // We only want to affect pixels where mask > 0, 
    // but the ColorRect is full screen. 
    // To allow the target area to be perfectly clear, 
    // we use the original scene color if mask is near 0.
    if (mask < 0.01) {
        COLOR = texture(screen_texture, uv);
    }
}