extern vec3 user_color; //user-defined color
extern Image mask; // defines areas to be recoloured

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	vec4 user_mask = Texel(mask, texture_coords);
	user_mask *= vec4(user_color, 1.0);
	vec4 diffuse = Texel(texture, texture_coords);
	diffuse *= color;
	return (diffuse * user_mask) + diffuse;
}