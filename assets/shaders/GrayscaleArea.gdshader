shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Sample what is behind the ColorRect on the screen
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    // Calculate luminance (grayscale)
    float gray = dot(screen_color.rgb, vec3(0.299, 0.587, 0.114));
    
    // Blend between original screen color and grayscale
    vec3 final_color = mix(screen_color.rgb, vec3(gray), intensity);
    
    COLOR = vec4(final_color, screen_color.a);
}