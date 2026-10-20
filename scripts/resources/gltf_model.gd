# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name GltfModel extends LoadableArtifact

var obj : GLTFObject
var preserve_scale: bool = false
var parent : Node3D
@export var artifactGltfUrl : String

func _load_gltf() -> GLTFObject:
	return null

func _create_material() -> GltfMaterial:
	return GltfMaterial.new(obj)
	
func set_up_load_artifact(par: Node3D):
	parent = par

func _add_runtime_collider(mesh_instance: MeshInstance3D):
	var static_body = StaticBody3D.new()
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = mesh_instance.mesh.create_convex_shape()  # or create_trimesh_shape()
	static_body.add_child(collision_shape)
	static_body.collision_layer = 1
	mesh_instance.add_child(static_body)
	load_completed.emit()

func load_artifact() -> int:
	obj = await _load_gltf()
	if obj == null:
		load_completed.emit()
		return -1
	
	var scene = obj.generate_scene()
	if scene == null:
		load_completed.emit()
		return -1
	
	add_child(scene)
	
	# Make sure that the scene isn't empty
	if scene.get_child(0, true) == null:
		load_completed.emit()
		return -1
	
	# 2x scale to account for mis-scaling of Kintsugi environments
	# Voyager models should not be scaled here since we need to scale up the scene root instead.
	if not preserve_scale:
		apply_scale_adjustment(scene)
		
	refresh_aabb()
	preview_load_completed.emit()
	
	var meshes = scene.find_children("*", "MeshInstance3D")
	var mesh_count : int = 1
	for mesh_instance : MeshInstance3D in meshes:
		#print("mesh_count ", mesh_count)
		mesh_count += 1
		var has_empty_materials
		if mesh_instance.mesh != null:
			# only replace empty materials
			# skip material load step completely if there are no empty materials
			var surface_count = mesh_instance.mesh.get_surface_count()
			for i in surface_count:
				has_empty_materials = has_empty_materials || mesh_instance.mesh.surface_get_material(i) == null
		
			if has_empty_materials:
				#print("loading external materials")
				var mat_loader = _create_material()
				mat_loader.load_complete.connect(_on_material_load_complete)
				mat_loader.load_progress.connect(_on_material_load_progress)
				
				for i in surface_count:
					if mesh_instance.mesh.surface_get_material(i) == null:
						mesh_instance.set_surface_override_material(i, mat_loader)
					
				mat_loader.load(mesh_instance)
			else:
				load_completed.emit() # no materials, done loading
		else:
			load_completed.emit() # no mesh, done loading (probably an error)
		_add_runtime_collider(mesh_instance)
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
