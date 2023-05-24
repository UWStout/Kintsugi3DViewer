shader_type spatial;

uniform sampler2D diffuseMap : source_color;
uniform sampler2D normalMap : hint_normal;
uniform sampler2D specularMap : hint_default_black;
uniform sampler2D roughnessMap : hint_default_white;

uniform sampler2D weights0123 : hint_default_black;
uniform sampler2D weights4567 : hint_default_black;
uniform sampler2D basisFunctions : hint_default_black;

const int BASIS_COUNT = 8;

vec3 evaluateBasisFunction(float w, int b)
{
	// Manual linear interpolation on one dimension
	int width = textureSize(basisFunctions, 0).x;
	float x = w * float(width - 1);
	int x0 = int(floor(x));
	int x1 = x0 + 1;
	float alpha = x - float(x0);
	
	return mix(texelFetch(basisFunctions, ivec2(x0, b), 0),
		texelFetch(basisFunctions, ivec2(x1, b), 0), alpha).rgb;
}

vec3 getMFDEstimateRaw(vec3 uvw)
{
    vec3 estimate = vec3(0);

	vec4 weightsLookup0123 = texture(weights0123, uvw.xy);
	for (int b = 0; b < 4; b++)
    {
        estimate += weightsLookup0123[b] * evaluateBasisFunction(uvw[2], b);
    }
	
	vec4 weightsLookup4567 = texture(weights4567, uvw.xy);
	for (int b = 4; b < 8; b++)
    {
        estimate += weightsLookup4567[b - 4] * evaluateBasisFunction(uvw[2], b);
    }

    return estimate;
}

vec3 getMFDEstimate(vec2 uv, float nDotH)
{
    float w = sqrt(max(0.0, acos(nDotH) * 3.0 / PI));
    return getMFDEstimateRaw(vec3(uv, w));
}

void fragment() 
{
	// Godot 4 is different than Godot 3 in that the diffuse texture is NOT automatically decoded
	// -- this is because it wants ALBEDO to be passed through gamma-encoded.
	// To use it for other purposes (like the hacky metallic heuristic), we need to decode it.
	vec3 diffuse = texture(diffuseMap, UV).rgb;
	vec3 diffuseLinear = pow(diffuse, vec3(2.2));
	
	// Both specular texture is designated as sRGB, so it gets automatically decoded.
	vec3 specularLinear = texture(specularMap, UV).rgb;
	
	NORMAL_MAP = texture(normalMap, UV).xyz;
	
	// TODO generate optimized metallic map when doing the specular fit
	vec3 metallicHeuristic = (specularLinear - 0.04) / (diffuseLinear + specularLinear - 0.04);
	METALLIC = //0.0;
		clamp(dot(vec3(1.0 / 3.0), metallicHeuristic), 0.0, 1.0);
		//max(0.0, min(metallicHeuristic.r, min(metallicHeuristic.g, metallicHeuristic.b)));
	ALBEDO = //vec3(0.0);
		pow(diffuseLinear + specularLinear, vec3(1.0 / 2.2));
		//diffuse / pow(1.0 - METALLIC, 1.0/2.2);

	ROUGHNESS = texture(roughnessMap, UV)[0]; // roughness = sqrt(m)
	
//	// Hard-coded for reverse-engineering BRDF
//	METALLIC = 1.0;
//	ALBEDO = pow(vec3(0.15, 0.05, 0.1),vec3(1.0/2.2));  // Godot 4 expects albedo to be gamma-encoded
//	ROUGHNESS = 0.5;  // roughness = sqrt(m)
	
//	// For testing
//	IRRADIANCE = vec4(0, 0, 0, 1);
//	RADIANCE = vec4(0, 0, 0, 1);
}

void light()
{
	// All calculations in view space, acc. to Godot shader docs
	float nDotL = max(0.0, dot(NORMAL, LIGHT));
	float nDotV = max(0.0, dot(NORMAL, VIEW));
	vec3 halfway = normalize(LIGHT + VIEW);
	float nDotH = max(0.0, dot(NORMAL, halfway));
	float hDotV = max(0.0, dot(halfway, VIEW));
	float m = ROUGHNESS * ROUGHNESS; // roughness = sqrt(m)
	float mSq = m * m;
	vec3 irradiance = LIGHT_COLOR * ATTENUATION * nDotL;

	vec3 mfdTimesFresnel = getMFDEstimate(UV, nDotH);
	float geomRatio = 0.5 / max(0.05, nDotV * sqrt(mix(nDotL * nDotL, 1, mSq) + nDotL * sqrt(mix(nDotV * nDotV, 1, mSq))));

	vec3 diffuse = texture(diffuseMap, UV).rgb;
	vec3 diffuseLinear = pow(diffuse, vec3(2.2));

	DIFFUSE_LIGHT += diffuseLinear / (ALBEDO * (1.0 - METALLIC) + step(1.0, METALLIC)) * irradiance; // Godot expects this to not be divided by pi

	// Fresnel effect
	vec3 f0 = mix(vec3(0.04), ALBEDO, METALLIC);
	float oneMinusHDotV = 1.0 - hDotV;
	float oneMinusHDotVSq = oneMinusHDotV * oneMinusHDotV;

	 // mfdTimesFresnel will come out pre-divided by pi, so we need to multiply by PI to cancel it out.
	SPECULAR_LIGHT += 
//		mfdTimesFresnel
	  	mix(mfdTimesFresnel, vec3(dot(mfdTimesFresnel / f0, vec3(1.0/3.0))), oneMinusHDotVSq * oneMinusHDotVSq * oneMinusHDotV)
			* geomRatio * irradiance * PI;
}
