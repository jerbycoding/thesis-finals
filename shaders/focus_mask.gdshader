shader_type canvas_item;

// Target position and size in normalized UV coordinates (0.0 to 1.0)
uniform vec2 target_uv_pos;
uniform vec2 target_uv_size;
uniform float dim_alpha : hint_range(0.0, 1.0) = 0.7;
uniform float softness : hint_range(0.0, 0.5) = 0.02;

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Calculate bounds in UV space
    vec2 half_size = target_uv_size * 0.5;
    vec2 center = target_uv_pos + half_size;
    
    // Standard Box SDF in UV space
    vec2 d = abs(uv - center) - half_size;
    float dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
    
    // Smooth mask
    float mask = smoothstep(0.0, softness, dist);
    
    COLOR = vec4(0.0, 0.0, 0.0, dim_alpha * mask);
}