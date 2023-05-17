shader_type spatial;

uniform sampler2D diffuseMap;
uniform sampler2D normalMap;
uniform sampler2D specularMap;
uniform sampler2D roughnessMap;

uniform sampler2DArray weights;
uniform sampler2DArray basisFunctions;

const int BASIS_COUNT = 8;

vec3 getMFDEstimateRaw(vec3 uvw)
{
    vec3 estimate = vec3(0);

    for (int b = 0; b < BASIS_COUNT; b++)
//	for (int b = 0; b < 4; b++)
    {
        estimate += texture(weights, vec3(uvw.xy, float(b)))[0] 
			* texture(basisFunctions, vec3(uvw.z, 0.0, float(b))).rgb;
    }
//	for (int b = 4; b < 8; b++)
//    {
//        estimate += texture(weights4567, uvw.xy)[0] 
//			* texture(basisFunctions, vec3(uvw.z, 0.0, float(b))).rgb;
//    }

    return estimate;
}

vec3 getMFDEstimate(vec2 uv, float nDotH)
{
    float w = sqrt(max(0.0, acos(nDotH) * 3.0 / PI));
    return getMFDEstimateRaw(vec3(uv, w));
}

void fragment() 
{
	ALBEDO = texture(diffuseMap, UV).rgb;
	NORMAL_MAP = texture(normalMap, UV).xyz;
	ROUGHNESS = texture(roughnessMap, UV)[0];
	// No slot for traditional specular color (uses metallic instead), 
	// so we'll have to look that up in the light() function.
}

void light()
{
	// All calculations in view space, acc. to Godot shader docs
	float nDotL = max(0.0, dot(NORMAL, LIGHT));
	float nDotV = max(0.0, dot(NORMAL, VIEW));
	vec3 halfway = normalize(LIGHT + VIEW);
	float nDotH = max(0.0, dot(NORMAL, halfway));
	float hDotV = max(0.0, dot(halfway, VIEW));
	float m = ROUGHNESS * ROUGHNESS;
	float mSq = m * m;
	vec3 irradiance = LIGHT_COLOR * ATTENUATION * nDotL;
	
	vec3 mfdTimesFresnel = getMFDEstimate(UV, nDotH);
	float geomRatio = 0.5 / (nDotV * sqrt(mix(nDotL * nDotL, 1, mSq) + nDotL * sqrt(mix(nDotV * nDotV, 1, mSq))));
	
	// TODO: Fresnel effect
	
	DIFFUSE_LIGHT += ALBEDO * irradiance; // Godot expects this to not be divided by pi
	
	 // mfdTimesFresnel will come out pre-divided by pi, so we need to multiply by PI to cancel it out.
	SPECULAR_LIGHT += mfdTimesFresnel * geomRatio * irradiance * PI;
}
