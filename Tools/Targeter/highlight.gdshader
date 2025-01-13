shader_type canvas_item;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV); // Sample the texture
    tex_color.rgb += vec3(0.2); // Add brightness to the RGB channels
    COLOR = tex_color; // Set the final color
}