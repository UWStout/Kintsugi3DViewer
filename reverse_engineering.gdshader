shader_type spatial;

vec3 toLinearSlow(vec3 col) 
{
    bvec3 cutoff = lessThan(col, vec3(0.04045));
    vec3 higher = pow((col + vec3(0.055))/vec3(1.055), vec3(2.4));
    vec3 lower = col/vec3(12.92);
    return mix(higher, lower, cutoff);
}

vec3 toSRGBSlow(vec3 col) 
{
    bvec3 cutoff = lessThan(col, vec3(0.0031308));
    vec3 higher = vec3(1.055)*pow(col, vec3(1.0/2.4)) - vec3(0.055);
    vec3 lower = col * vec3(12.92);
    return mix(higher, lower, cutoff);
}

void fragment() 
{
	ALBEDO = toSRGBSlow(vec3(0.15, 0.05, 0.1));//pow(vec3(0.15, 0.05, 0.1), vec3(1.0/2.3));
	METALLIC = 0.5;
	ROUGHNESS = 0.5; // roughness = sqrt(m)
	IRRADIANCE = vec4(0, 0, 0, 1);
	RADIANCE = vec4(0, 0, 0, 1);
}
