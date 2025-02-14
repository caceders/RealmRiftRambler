shader_type canvas_item;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV); // Sample the texture
    tex_color.rgb -= vec3(.5, .5, 0); // Give a blue hue
    COLOR = tex_color; // Set the final color
}