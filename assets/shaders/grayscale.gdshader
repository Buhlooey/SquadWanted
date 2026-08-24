shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float glow: hint_range(1.0, 5.0) = 1.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	vec3 final_color = mix(tex_color.rgb, vec3(gray), intensity);
    COLOR = vec4(glow) * vec4(final_color, tex_color.a);
}