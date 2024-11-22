# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name LocalGltfModel extends GltfModel

func _load_gltf() -> GLTFObject:
	if not artifact.gltfUri.ends_with(".gltf") and not artifact.gltfUri.ends_with(".glb"):
		return null
	
	var file = FileAccess.open(artifact.gltfUri, FileAccess.READ)
	if not file:
		return null
	
	var buffer = file.get_buffer(file.get_length())
	
	var gltf = GLTFDocument.new()
	var gltf_state = GLTFState.new()
	
	var error = gltf.append_from_file(artifact.gltfUri, gltf_state, 0x20)
	if error:
		return null
	
	var gltf_obj = GLTFObject.new()
	gltf_obj.document = gltf
	gltf_obj.state = gltf_state
	gltf_obj.sourceUri = artifact.gltfUri
	return gltf_obj

func _create_material() -> GltfMaterial:
	return LocalGltfMaterial.new(obj)

static func create(p_artifact : ArtifactData):
	var model = LocalGltfModel.new()
	model.artifact = p_artifact
	model.is_local = true
	return model
