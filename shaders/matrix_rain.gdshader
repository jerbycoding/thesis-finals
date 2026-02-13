shader_type canvas_item;

uniform float speed : hint_range(0.0, 5.0) = 1.0;
uniform float density : hint_range(0.0, 50.0) = 25.0;
uniform vec4 color : source_color = vec4(0.0, 1.0, 0.2, 1.0);
uniform float brightness : hint_range(0.0, 2.0) = 1.0;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV;
    
    // Create columns
    float col = floor(uv.x * density);
    
    // Randomize speed per column
    float col_speed = random(vec2(col, 13.0)) * 0.5 + 0.5;
    float time = TIME * speed * col_speed;
    
    // Create 'falling' character rows
    float row = floor(uv.y * density * 2.0 - time);
    
    // Calculate character trail intensity
    float trail = fract(uv.y * density * 0.1 - time * 0.1);
    trail = pow(trail, 3.0); // Sharpen the tail
    
    // Randomize 'character' lookup (noise)
    float char_noise = random(vec2(col, row));
    
    // Final composite
    float mask = step(0.5, char_noise); // Digital binary feel
    vec3 final_color = color.rgb * trail * mask * brightness;
    
    // Add "leading head" glow
    if (trail > 0.95) {
        final_color += color.rgb * 0.5;
    }
    
    COLOR = vec4(final_color, trail * color.a);
}
