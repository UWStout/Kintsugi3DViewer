# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name GltfMaterial extends ShaderMaterial

signal load_complete
signal load_progress(complete : int, total : int)

var _gltf : GLTFObject
var _parent : Node

var images : Array
var _resources_loaded : Dictionary

const SHADER_IBR = preload("res://shaders/BasisIBR.gdshader")
const SHADER_ORM_IBR = preload("res://shaders/BasisIBR-ORM.gdshader")
const SHADER_STANDARD = preload("res://shaders/standard_shader.gdshader")

func _init(p_gltf : GLTFObject):
	_gltf = p_gltf

func load(parent : Node):
	_parent = parent
	_resources_loaded = {}
	
	var mesh_index = _get_self_mesh_index(parent, _gltf.state)
	if mesh_index < 0:
		return
	
	var mesh = _gltf.state.json.get("meshes")[mesh_index]
	var material_index = mesh.get("primitives")[0].get("material")
	if material_index == null:
		material_index = 0
	var material = _gltf.state.json.get("materials")[material_index]
	images = _gltf.state.json.get("images")
	
	# Load the correct shader
	select_shader(material)
	# Populate the requested textures into the dictionary
	request_texture_keys(material)
	
	if material.has("pbrMetallicRoughness"):
		_load_pbr_material(material["pbrMetallicRoughness"])
	
	if material.has("normalTexture"):
		_load_image(material["normalTexture"], "normalMap")
	
	if material.has("extras"):
		_load_ibr_material(material["extras"])
		_load_ibr_common_textures(material["extras"])
	
	_update_progress()

func _load_ibr_common_textures(ibr : Dictionary):
	if ibr.has("basisFunctionsUri"):
		_load_basis_functions(ibr)
	if ibr.has("specularWeights"):
		_load_specular_weights(ibr["specularWeights"])

func _load_pbr_material(pbr : Dictionary):
	if pbr.has("baseColorTexture"):
		_load_image(pbr["baseColorTexture"], "albedoMap")
	if pbr.has("metallicRoughnessTexture"):
		_load_image(pbr["metallicRoughnessTexture"], "ormMap")

func _load_ibr_material(ibr : Dictionary):
	if ibr.has("diffuseTexture") and _shader_wants("diffuseMap"):
		_load_image(ibr["diffuseTexture"], "diffuseMap")
	if ibr.has("specularTexture") and _shader_wants("specularMap"):
		_load_image(ibr["specularTexture"], "specularMap")
	if ibr.has("roughnessTexture") and _shader_wants("roughnessMap"):
		_load_image(ibr["roughnessTexture"], "roughnessMap")
	if ibr.has("diffuseConstantTexture") and _shader_wants("constantMap"):
		_load_image(ibr["diffuseConstantTexture"], "constantMap")




# Override for children
func _load_specular_weights(weights : Dictionary):
	pass

# Override for children
func _load_basis_functions(ibr : Dictionary):
	pass

# Override for children
func _load_image(texture_info : Dictionary, shader_key : String):
	pass




func _info_to_tex(texture_info: Dictionary) -> Dictionary:
	return _gltf.state.json["textures"][texture_info["index"]]

func _load_shader_image(image : Image, shader_key : String):
	if _resources_loaded.has(shader_key):
		_resources_loaded[shader_key] = true
	
	image.generate_mipmaps()
	
	var texture := ImageTexture.create_from_image(image)
	set_shader_parameter(shader_key, texture)
	
	_update_progress()

func select_shader(material):
	if (material.has("extras") and
	material["extras"].has_all(["basisFunctionsUri", "specularWeights"])):
		if material["extras"].has("roughnessTexture"):
			shader = SHADER_IBR
		else:
			shader = SHADER_ORM_IBR
	else:
		shader = SHADER_STANDARD

func request_texture_keys(material : Dictionary):
	if material.has("pbrMetallicRoughness"):
		_resources_loaded["albedoMap"] = false
	if material.has("normalTexture"):
		_resources_loaded["normalMap"] = false
	if material.has("extras"):
		if material["extras"].has("diffuseTexture") and _shader_wants("diffuseMap"):
			_resources_loaded["diffuseMap"] = false
		if material["extras"].has("specularTexture") and _shader_wants("specularMap"):
			_resources_loaded["specularMap"] = false
		if material["extras"].has("roughnessTexture") and _shader_wants("roughnessMap"):
			_resources_loaded["roughnessMap"] = false
		if material["extras"].has("basisFunctionsUri"):
			_resources_loaded["basisFunctions"] = false
		if material["extras"].has("specularWeights"):
			_resources_loaded["weights0123"] = false
			_resources_loaded["weights4567"] = false

func _shader_wants(key: String) -> bool:
	var uniforms = shader.get_shader_uniform_list()
	for uniform in uniforms:
		if uniform.name == key:
			return true
	return false

func _basis_csv_to_image(in_csv: Array) -> Image:
	var width = 0
	var data = PackedFloat32Array()
	
	for l in range(0, in_csv.size(), 3):
		var red = in_csv[l]
		var green = in_csv[l + 1]
		var blue = in_csv[l + 2]
		
		if width == 0:
			width = red.size() - 1
		
		if red.size() >= 2:
			for i in width:
				data.append(float(red[i + 1]))
				data.append(float(green[i + 1]))
				data.append(float(blue[i + 1]))
	return Image.create_from_data(width, in_csv.size() / 3, false, Image.FORMAT_RGBF, data.to_byte_array())

func _get_self_mesh_index(parent: Node, state: GLTFState) -> int:
	for mesh in state.meshes:
		if parent.mesh.resource_name == mesh.mesh.resource_name:
			return state.meshes.find(mesh)
	return -1

func _update_progress():
	var progress = _get_load_progress()
	load_progress.emit(progress[0], progress[1])
	if progress[0] >= progress[1]:
		load_complete.emit()

func _get_load_progress() -> Array[int]:
	var items = 0
	for key in _resources_loaded.keys():
		if _resources_loaded[key]:
			items += 1
	return [items, _resources_loaded.size()]

func _format_gltf_relative_uri(uri: String) -> String:
	var folder = _gltf.sourceUri.get_base_dir()
	return folder.path_join(uri)
