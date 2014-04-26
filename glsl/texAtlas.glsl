extern vec4 cel_size;
extern vec2 current_cel;
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
	vec4 cel = vertex_position * cel_size;
	gl_TexCoord[0] *= cel_size;
	gl_TexCoord[0] += vec4(current_cel.r - 1, current_cel.g - 1, 0, 0) * cel_size;
	return transform_projection * cel;
}