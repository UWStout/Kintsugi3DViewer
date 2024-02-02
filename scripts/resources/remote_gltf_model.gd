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

func _ready():
	# Ensure the resource fetcher is avaliable
	if not is_instance_valid(fetcher):
		fetcher = GlobalFetcher
		if not is_instance_valid(fetcher):
			push_error("Remote glTF loader at node %s could not find a valid resource fetcher!" % get_path())
			return
	
	# If a URL is provided, override the artifact and load on ready. Used for testing.
	if not artifactGltfUrl.is_empty():
		artifact = ArtifactData.new()
		artifact.gltfUri = artifactGltfUrl
		#load_artifact()


#func load_artifact() -> int:
#	var imported = null
#
#	var dir_name = artifact.gltfUri.get_base_dir()
#	var file_name = artifact.gltfUri.trim_prefix(dir_name + "/")
#	file_name = file_name.trim_suffix(".glb")
#	file_name = file_name.trim_suffix(".gltf")
#
#	imported = CacheManager.import_gltf(dir_name, file_name)
#
#	if not imported == null:
#		obj = GLTFObject.new()
#		obj.document = imported.doc
#		obj.state = imported.state
#		obj.sourceUri = artifact.gltfUri
#	elif not Preferences.read_pref("offline mode"):
#		obj = await fetcher.fetch_gltf(artifact)
#		print("fetched!")
#
#	if obj == null:
#		print("COULDN'T FETCH GLTF")
#		return -1
#
#	# if the import failed, then there isn't a GLTF file exported
#	# to the cache, so we should export this one
#	if imported == null:
#		print(obj.sourceUri)
#		CacheManager.export_gltf(dir_name, file_name, obj.document, obj.state.duplicate())
#		CacheManager.export_artifact_data(dir_name, artifact)
#
#	var scene = obj.generate_scene()
#
#	if scene == null:
#		push_error("Failed to load glTF into scene!")
#		return -1
#
#	add_child(scene)
#
#	# TODO: Support multiple materials by scanning entire subtree/glTF data to find meshes
#	# instead of just grabbing the first child node and hoping its a mesh!
#	var mesh = scene.get_child(0, true)
#
#	if mesh.get_aabb() != null:
#		aabb = mesh.get_aabb()
#	else:
#		aabb = AABB()
#
#	mat_loader = RemoteGltfMaterial.new(fetcher, obj)
#
#	mat_loader.load_complete.connect(_on_material_load_complete)
#	mat_loader.load_progress.connect(_on_material_load_progress)
#
#	mesh.set_surface_override_material(0, mat_loader)
#	mat_loader.load(mesh)
#
#	return 1

func _load_gltf() -> GLTFObject:
	var imported = null
	
	var dir_name = artifact.gltfUri.get_base_dir()
	var file_name = artifact.gltfUri.trim_prefix(dir_name + "/")
	file_name = file_name.trim_suffix(".glb")
	file_name = file_name.trim_suffix(".gltf")

	imported = CacheManager.import_gltf(dir_name, file_name)
	
	if not imported == null:
		var gltf_obj = GLTFObject.new()
		gltf_obj.document = imported.doc
		gltf_obj.state = imported.state
		gltf_obj.sourceUri = artifact.gltfUri
		return gltf_obj
	elif not Preferences.read_pref("offline mode"):
		var gltf_obj = await fetcher.fetch_gltf(artifact)
		
		CacheManager.export_artifact_data(dir_name, artifact)
		Thread.new().start(CacheManager.export_gltf.bind(dir_name, file_name, gltf_obj.document, gltf_obj.state.duplicate()))
		
		return gltf_obj
	
	return null

func _create_material() -> GltfMaterial:
	return RemoteGltfMaterial.new(fetcher, obj)

static func create(p_artifact: ArtifactData) -> RemoteGltfModel:
	var model = RemoteGltfModel.new()
	model.artifact = p_artifact
	model.is_local = false
	return model
