shader_type spatial;

// depth_prepass_alpha fixes sorting bugs with other transparent objects
render_mode blend_mix, depth_prepass_alpha, cull_disabled;

// Godot automatically injects the Sprite3D's texture here if named exactly like this
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap;
// Slider to control the overall opacity of the sprite
uniform float alpha_multiplier : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	// Sample the texture color at the current UV coordinates
	vec4 color = texture(texture_albedo, UV);

	// Assign RGB to the final Albedo color
	ALBEDO = color.rgb;

	// Multiply the texture's alpha channel by your transparency slider
	ALPHA = color.a * alpha_multiplier;
}
