# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends GltfModel
class_name RemoteGltfModel

@export var fetcher: ResourceFetcher

func check_fetcher():
	# Ensure the resource fetcher is avaliable
	if not is_instance_valid(fetcher):
		fetcher = GlobalFetcher
		if not is_instance_valid(fetcher):
			push_error("Remote glTF loader at node %s could not find a valid resource fetcher!" % get_path())
			return

func _ready():
	# Ensure the resource fetcher is avaliable
	check_fetcher()
	
	# If a URL is provided, override the artifact and load on ready. Used for testing.
	if not artifactGltfUrl.is_empty():
		artifact = ArtifactData.new()
		artifact.gltfUri = artifactGltfUrl
		#load_artifact()

func _load_gltf() -> GLTFObject:
	
	# might not have called _ready() yet
	check_fetcher()
	
	var imported : GLTFObject = null 
	
	var dir_name = artifact.gltfUri.get_base_dir()
	var file_name = artifact.gltfUri.trim_prefix(dir_name + "/")
	file_name = file_name.trim_suffix(".glb")
	file_name = file_name.trim_suffix(".gltf")

	imported = CacheManager.import_gltf(dir_name, file_name)
	
	if not imported == null:
		var gltf_obj = imported
		gltf_obj.sourceUri = artifact.gltfUri
		return gltf_obj
	elif not Preferences.read_pref("offline mode"):
		#print(Preferences.read_pref("offline mode"))
		var gltf_obj = await fetcher.fetch_gltf(artifact)
		CacheManager.export_artifact_data(dir_name, artifact)
		CacheManager.export_gltf_async(dir_name, file_name, gltf_obj.document, gltf_obj.state.duplicate(true))
		
		return gltf_obj
	
	return null

func _create_material() -> GltfMaterial:
	return RemoteGltfMaterial.new(fetcher, obj)

static func create(p_artifact: ArtifactData) -> RemoteGltfModel:
	var model = RemoteGltfModel.new()
	model.artifact = p_artifact
	model.is_local = false
	return model
