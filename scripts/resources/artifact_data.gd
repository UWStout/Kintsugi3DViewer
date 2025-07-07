# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends RefCounted


class_name ArtifactData

var name: String
var iconUri: String
var gltfUri: String
var voyagerUri: String 
var cameraloaded:bool
var cameraZoominSetting : float
var cameraZoomoutSetting : float

static func from_dict(data: Dictionary) -> ArtifactData:
	var out_data = ArtifactData.new()
	
	if data.has("name"):
		out_data.name = data.get("name")
	
	if data.has("iconUri"):
		out_data.iconUri = data.get("iconUri")
	
	if data.has("gltfUrl"): #Backwards compatability with Url instead of Uri
		out_data.gltfUri = data.get("gltfUrl")
	
	if data.has("gltfUri"):
		out_data.gltfUri = data.get("gltfUri")
	var cameraloaded = false
	if data.has("camerZoominSetting"):
		out_data.cameraZoominSetting = data.get("cameraZoominSetting")
	if data.has("camerZoomoutSetting"):
		out_data.cameraZoomoutSetting = data.get("cameraZoomoutSetting")
		cameraloaded = true
		
	#if cameraloaded == true:
	#	cameraZoominsetting = 
	if data.has("voyagerUri"):
		out_data.voyagerUri = data.get("voyagerUri")
	
	return out_data

func _to_string() -> String:
	return name
