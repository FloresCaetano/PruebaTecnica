shader_type canvas_item;
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
    vec4 flashed_color = mix(texture_color, vec4(flash_color.rgb, texture_color.a), flash_modifier);
    
    COLOR = flashed_color;
}