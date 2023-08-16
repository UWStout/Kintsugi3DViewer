# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

shader_type spatial;

uniform sampler2D diffuseMap : source_color, filter_linear_mipmap;
uniform sampler2D normalMap : hint_normal, filter_linear_mipmap;
uniform sampler2D specularMap : hint_default_black, filter_linear_mipmap;
uniform sampler2D roughnessMap : hint_default_white, filter_linear_mipmap;

uniform sampler2D weights0123 : hint_default_black, filter_linear_mipmap;
uniform sampler2D weights4567 : hint_default_black, filter_linear_mipmap;
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
	
	// Specular texture is not designated as sRGB.
	vec3 specularLinear = pow(texture(specularMap, UV).rgb, vec3(2.2));
	
	NORMAL_MAP = texture(normalMap, UV).xyz;
	
	vec3 diffusePlusSpecular = diffuseLinear + specularLinear;
	
//	// Adjust for dielectic specular (i.e. 0.04 for non-metallic)
//    // See derivation above
//    // Initially, calculate albedo assuming metallicity could be different for each RGB channel (for simplicity)
//    vec3 albedoLinear = 0.5 * diffusePlusSpecular + 0.5 * sqrt(max(vec3(0.0), diffusePlusSpecular * diffusePlusSpecular - 0.16 * diffuseLinear));
//
//    // Then calculate metallicity for all channels
//    vec3 metallicity = clamp(1.0 - diffuseLinear / albedoLinear, 0.0, 1.0);
//
//    // Take the highest metallicity of all the color channels (most conservative in terms of preserving color information in specular highlights)
//    float maxMetallicity = max(metallicity.r, max(metallicity.g, metallicity.b));
//
//    // Recalculate albedo now assuming a single metallicity for the R, G, and B channels
//    albedoLinear = diffusePlusSpecular - 0.04 * (1.0 - maxMetallicity);

    vec3 albedoLinear = diffusePlusSpecular;
	
	vec3 metallicHeuristic = (specularLinear - 0.04) / (diffuseLinear + specularLinear - 0.04);
	METALLIC = // 0.0;
		//maxMetallicity;
		clamp(dot(vec3(1.0 / 3.0), metallicHeuristic), 0.0, 1.0);
		//max(0.0, min(metallicHeuristic.r, min(metallicHeuristic.g, metallicHeuristic.b)));
	ALBEDO = //vec3(0.0);
		pow(albedoLinear, vec3(1.0 / 2.2));
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

	// Godot appears to divide by PI for normalized Lambertian
	DIFFUSE_LIGHT += diffuseLinear / (PI * ALBEDO * (1.0 - METALLIC) + step(1.0, METALLIC)) * irradiance; // Godot expects this to not be divided by pi

	// Fresnel effect
	vec3 f0 = mix(vec3(0.04), ALBEDO, METALLIC);
	float oneMinusHDotV = 1.0 - hDotV;
	float oneMinusHDotVSq = oneMinusHDotV * oneMinusHDotV;

//	// Debugging
//	f0 = pow(texture(specularMap, UV).rgb, vec3(2.2));
//	float nDotHSq = nDotH * nDotH;
//	float sqrtDen = mix(1.0, mSq, nDotHSq);
//	mfdTimesFresnel = f0 * mSq / (PI * sqrtDen * sqrtDen);

	// Godot does not automatically / implicitly divide by pi, so no multiplication by PI is necessary.
	SPECULAR_LIGHT += 
//		mfdTimesFresnel
	  	mix(mfdTimesFresnel, vec3(dot(mfdTimesFresnel / f0, vec3(1.0/3.0))), oneMinusHDotVSq * oneMinusHDotVSq * oneMinusHDotV)
			* geomRatio * irradiance;
}
