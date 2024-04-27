# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name GltfModel extends Node3D

var is_local : bool = false

var mat_loader : GltfMaterial
var obj : GLTFObject
var aabb : AABB

signal preview_load_completed
signal load_completed
signal load_progress(estimation : float)

@export var artifactGltfUrl : String

var artifact: ArtifactData = null
var load_finished : bool = false

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
	
	var mesh = scene.get_child(0, true)
	if mesh == null:
		return -1
	
	if not mesh.get_aabb() == null:
		aabb = mesh.get_aabb() * mesh.global_transform
	else:
		aabb = AABB() * mesh.global_transform
		
	preview_load_completed.emit();
	
	mat_loader = _create_material()
	mat_loader.load_complete.connect(_on_material_load_complete)
	mat_loader.load_progress.connect(_on_material_load_progress)
	
	mesh.set_surface_override_material(0, mat_loader)
	
	mat_loader.load(mesh)
	
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
