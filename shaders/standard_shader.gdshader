// Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
//
// Licensed under GPLv3
// ( http://www.gnu.org/licenses/gpl-3.0.html )
//
// This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.//# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

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
