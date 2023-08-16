// Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
//
// Licensed under GPLv3
// ( http://www.gnu.org/licenses/gpl-3.0.html )
//
// This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
// This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

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
