extern vec3 user_color; //user-defined color
extern vec3 user_color_sub
extern Image mask; // defines areas to be recoloured
extern Image mask_sub; // secondary colour mask

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	//primary colour
	vec4 user_mask = Texel(mask, texture_coords);
	user_mask *= vec4(user_color, 1.0);

	//sub colour
	vec4 user_mask_sub = Texel(mask_sub, texture_coords);
	user_mask_sub *= vec4(user_color_sub, 1.0)

	//plain diffuse
	vec4 diffuse = Texel(texture, texture_coords);
	diffuse *= color;
	return (diffuse * user_mask) + (diffuse * user_mask_sub) + diffuse;
}