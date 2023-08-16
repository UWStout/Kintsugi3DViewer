# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends ShaderMaterial
class_name RemoteGltfMaterial

signal load_complete
signal load_progress(complete: int, total: int)

var _fetcher: ResourceFetcher
var _gltf: GLTFObject
var _parent: Node

var _resources_loaded: Dictionary

const SHADER_IBR = preload("res://shaders/BasisIBR.gdshader")
const SHADER_ORM_IBR = preload("res://shaders/BasisIBR-ORM.gdshader")
const SHADER_STANDARD = preload("res://shaders/standard_shader.gdshader")

func _init(p_fetcher: ResourceFetcher, p_gltf: GLTFObject):
	_fetcher = p_fetcher
	_gltf = p_gltf


func load(parent: Node):
	_parent = parent
	_resources_loaded = {}

	if not _gltf.state.json.has("materials"):
		return
	
	var index = _get_self_mesh_index(parent, _gltf.state)
	if index < 0:
		return
	
	var mesh = _gltf.state.json.get("meshes")[index]
	var material_index = mesh.get("primitives")[0].get("material")
	var material = _gltf.state.json.get("materials")[material_index]
	
	# Load the correct shader
	if (material.has("extras") and
	material["extras"].has_all(["basisFunctionsUri", "specularWeights"])):
		if material["extras"].has("roughnessTexture"):
			shader = SHADER_IBR
		else:
			shader = SHADER_ORM_IBR
	else:
		shader = SHADER_STANDARD
	
	request_texture_keys(material)
	
	if material.has("pbrMetallicRoughness"):
		_load_pbr_material(material["pbrMetallicRoughness"])
	
	if material.has("normalTexture"):
		_start_tex_load(_info_to_tex(material["normalTexture"]), "normalMap")
	
	if material.has("extras"):
		_load_ibr_material(material["extras"])
		_load_ibr_common_textures(material)
	
	_update_progress()


func _info_to_tex(texture_info: Dictionary) -> Dictionary:
	return _gltf.state.json["textures"][texture_info["index"]]


func _start_tex_load(texture: Dictionary, key: String):
	print("Starting texture load for " + key)
	_resources_loaded[key] = false
	var texture_loader = RemoteGltfTexture.new(self, texture, key)
	_parent.add_child(texture_loader)
	texture_loader.texture_loaded.connect(_texture_loader_completion)
	texture_loader.load()



func _texture_loader_completion(key: String):
	_resources_loaded[key] = true
	_update_progress()


# Loads textures common to IBR shader modes
func _load_ibr_common_textures(material: Dictionary):
	# Load textures stored in material extras data
	if material.has("extras"):
		var extras = material.get("extras")
		
		if extras.has("basisFunctionsUri"):
			_resources_loaded["basisFunctions"] = false
			
			var imported = CacheManager.import_png(_gltf.sourceUri.get_base_dir(), "basisFunctions")
			if not imported == null:
				_load_shader_image(imported, "basisFunctions")
			else:
				var uri = _format_gltf_relative_uri(extras["basisFunctionsUri"])
				_fetcher.fetch_csv_callback(uri, func(csv):
					var img = _basis_csv_to_image(csv)
					img = _process_image(img, Image.FORMAT_RGBF)
					_load_shader_image(img, "basisFunctions")
				)
		
		if extras.has("specularWeights"):
			var weights = extras["specularWeights"]
			_load_specular_weights(weights)


func _load_pbr_material(pbr: Dictionary):
	if pbr.has("baseColorTexture"):
		_start_tex_load(_info_to_tex(pbr["baseColorTexture"]), "albedoMap")
		
	if pbr.has("metallicRoughnessTexture"):
		_start_tex_load(_info_to_tex(pbr["metallicRoughnessTexture"]), "ormMap")


func _load_ibr_material(extras: Dictionary):
	if extras.has("diffuseTexture") and _shader_wants("diffuseMap"):
		_start_tex_load(_info_to_tex(extras["diffuseTexture"]), "diffuseMap")

	if extras.has("specularTexture") and _shader_wants("specularMap"):
		_start_tex_load(_info_to_tex(extras["specularTexture"]), "specularMap")
	
	if extras.has("roughnessTexture") and _shader_wants("roughnessMap"):
		_start_tex_load(_info_to_tex(extras["roughnessTexture"]), "roughnessMap")
	
	if extras.has("diffuseConstantTexture") and _shader_wants("constantMap"):
		_start_tex_load(_info_to_tex(extras["diffuseConstantTexture"]), "constantMap")


func _load_specular_weights(weights: Dictionary):
	# Validate that specular weights object has required properties
	if ((not weights.has_all(["stride", "textures"])) or 
	weights.get("textures").size() <= 0):
		push_error("Malformed specular weights extra data block: %s" % weights)
		return
	
	const shaderKeys = ["weights0123", "weights4567"]
	
	if weights.get("stride") == 4 and weights.get("textures").size() >= 2:
		# No conversion to RGBA is needed, Load upper and lower weights directly
		for i in 2:
			_start_tex_load(_info_to_tex(weights["textures"][i]), shaderKeys[i])
	else:
		var uris: Array[String] = []
		for texture in weights.get("textures"):
			var texIdx = texture["index"]
			var imgIdx = _gltf.state.json["textures"][texIdx]["source"]
			var uri = _gltf.state.json["images"][imgIdx]["uri"]
			uris.append(_format_gltf_relative_uri(uri))
		
		var format = weights.get("stride") + 1
		var converter = RemoteTextureCombiner.new(_fetcher, format, uris)
		_parent.add_child(converter)
		
		converter.output_format = Image.FORMAT_RGBA8
		
		converter.combination_complete.connect(func(images):
			for i in images.size():
				_load_shader_image(images[i], shaderKeys[i])
			converter.queue_free()
		)
		
		converter.combine()


func _get_self_mesh_index(parent: Node, state: GLTFState) -> int:
	for mesh in state.meshes:
		if parent.mesh.resource_name == mesh.mesh.resource_name:
			return state.meshes.find(mesh)
	return -1


func _format_gltf_relative_uri(uri: String) -> String:
	var folder = _gltf.sourceUri.get_base_dir()
	return folder.path_join(uri)


func _process_image(image: Image, format) -> Image:
	image.generate_mipmaps()
	image.convert(format)
	return image


func _load_shader_image(image: Image, shaderKey: String):
	if _resources_loaded.has(shaderKey):
		_resources_loaded[shaderKey] = true
	
	CacheManager.export_png(_gltf.sourceUri.get_base_dir(), shaderKey, image)
	
	var texture := ImageTexture.create_from_image(image)
	set_shader_parameter(shaderKey, texture)
	
	_update_progress()


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


func _shader_wants(key: String) -> bool:
	var uniforms = shader.get_shader_uniform_list()
	for uniform in uniforms:
		if uniform.name == key:
			return true
	return false


func request_texture_keys(material : Dictionary):
	if material.has("pbrMetallicRoughness"):
		_resources_loaded["albedoMap"] = false
		print("wants albedoMap")
	if material.has("normalTexture"):
		_resources_loaded["normalMap"] = false
		print("wants normalMap")
	if material.has("extras"):
		if material["extras"].has("diffuseTexture") and _shader_wants("diffuseMap"):
			_resources_loaded["diffuseMap"] = false
			print("wants diffuseMao")
		if material["extras"].has("specularTexture") and _shader_wants("specularMap"):
			_resources_loaded["specularMap"] = false
			print("wants specularMap")
		if material["extras"].has("roughnessTexture") and _shader_wants("roughnessMap"):
			_resources_loaded["roughnessMap"] = false
			print("wants roughnessMap")
		if material["extras"].has("basisFunctionsUri"):
			_resources_loaded["basisFunctions"] = false
			print("wants basisFunctions")
		if material["extras"].has("specularWeights"):
			_resources_loaded["weights0123"] = false
			print("wants weights0123")
			_resources_loaded["weights4567"] = false
			print("wants weights4567")
