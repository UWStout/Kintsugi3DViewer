# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name GltfModel extends LoadableArtifact

var obj : GLTFObject

@export var artifactGltfUrl : String

func _load_gltf() -> GLTFObject:
	return null

func _create_material() -> GltfMaterial:
	return GltfMaterial.new(obj)

func load_artifact() -> int:
	obj = await _load_gltf()
	if obj == null:
		return -1
	
	var scene = obj.generate_scene()
	if scene == null:
		return -1
	
	add_child(scene)
	var error = refresh_aabb()
	if error != 0:
		return error
		
	preview_load_completed.emit();
	
	var meshes = scene.find_children("*", "MeshInstance3D")
	for mesh : MeshInstance3D in meshes:
		var has_empty_materials
		if mesh.mesh != null:
			# only replace empty materials
			# skip material load step completely if there are no empty materials
			var surface_count = mesh.mesh.get_surface_count()
			for i in surface_count:
				has_empty_materials = has_empty_materials || mesh.mesh.surface_get_material(i) == null
		
			if has_empty_materials:
				print("loading external materials")
				var mat_loader = _create_material()
				mat_loader.load_complete.connect(_on_material_load_complete)
				mat_loader.load_progress.connect(_on_material_load_progress)
				
				for i in surface_count:
					if mesh.mesh.surface_get_material(i) == null:
						mesh.set_surface_override_material(i, mat_loader)
					
				mat_loader.load(mesh)
			else:
				load_completed.emit() # no materials, done loading
		else:
			load_completed.emit() # no mesh, done loading (probably an error)
	
	return 0

func _on_material_load_complete():
	load_completed.emit()
	load_finished = true

func _on_material_load_progress(complete: int, total: int):
	total += 1
	if obj != null:
		complete += 1
	var progress = float(complete) / (total)
	load_progress.emit(progress)

static func create(p_artifact : ArtifactData):
	var model = GltfModel.new()
	model.artifact = p_artifact
	return model
