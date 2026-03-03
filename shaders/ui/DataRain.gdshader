shader_type canvas_item;

uniform float scroll_speed : hint_range(0.1, 5.0) = 0.8;
uniform float density : hint_range(0.01, 0.5) = 0.05;
uniform vec4 color : source_color = vec4(0.0, 1.0, 0.0, 0.05);

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;
    
    // Create columns
    float col_id = floor(uv.x * 50.0);
    float col_rand = rand(vec2(col_id, 31.0));
    
    // Staggered vertical scroll
    float scroll = fract(uv.y + TIME * scroll_speed * (0.5 + col_rand));
    
    // Create "blocks" of data
    float row = floor(scroll * 30.0);
    float char_rand = rand(vec2(col_id, row));
    
    // Only show "chars" based on density
    float brightness = step(1.0 - density, char_rand);
    
    // Fade at the edges of the blocks
    brightness *= smoothstep(0.0, 0.1, scroll) * smoothstep(1.0, 0.9, scroll);
    
    COLOR = color * brightness;
}
