shader_type spatial;

uniform sampler2D albedoMap : source_color, filter_linear_mipmap;
uniform sampler2D normalMap : hint_normal, filter_linear_mipmap;
uniform sampler2D ormMap : hint_default_white, filter_linear_mipmap;

void fragment() {
	ALBEDO = texture(albedoMap, UV).rgb;
	NORMAL_MAP = texture(normalMap, UV).xyz;
	
	vec3 orm = texture(ormMap, UV).xyz;
	AO = orm[0];
	ROUGHNESS = orm[1];
	METALLIC = orm[2];
}
