shader_type canvas_item;
uniform vec2 scroll_ratio;
uniform vec2 scroll_pos;
uniform vec4 colour_base:hint_color;
void fragment()
{
	vec2 shifteduv = UV;
	shifteduv += scroll_pos * scroll_ratio;
	vec4 colour = texture(TEXTURE,shifteduv);
	vec4 newcolour = mix(colour,colour_base,0.25);
	COLOR = newcolour;
}