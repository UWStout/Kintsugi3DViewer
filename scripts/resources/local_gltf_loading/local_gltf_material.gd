# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name LocalGltfMaterial extends ShaderMaterial

signal load_complete
signal load_progress(complete : int, total : int)

var _gltf : GLTFObject
var _parent : Node

var _resources_loaded : Dictionary

const SHADER_IBR = preload("res://shaders/BasisIBR.gdshader")
const SHADER_ORM_IBR = preload("res://shaders/BasisIBR-ORM.gdshader")
const SHADER_STANDARD = preload("res://shaders/standard_shader.gdshader")

func _init(p_gltf : GLTFObject):
	_gltf = p_gltf

func load_mat(parent : Node):
	_parent = parent
	_resources_loaded = {}
	
	var mesh_index = _get_self_mesh_index(parent, _gltf.state)
	if mesh_index < 0:
		return
	
	#print(_gltf.state.json)
	
	var mesh = _gltf.state.json.get("meshes")[mesh_index]
	var material_index = mesh.get("primitives")[0].get("material")
	if material_index == null:
		material_index = 0
	var material = _gltf.state.json.get("materials")[material_index]
	var images = _gltf.state.json.get("images")
	
	# Load the correct shader
	select_shader(material)
	# Populate the requested textures into the dictionary
	request_texture_keys(material)
	
	# Load base PBR Textures
	if material.has("pbrMetallicRoughness"):
		_load_pbr_material(material["pbrMetallicRoughness"], images)
	
	# Load NormalMap Texture
	if material.has("normalTexture"):
		var tex_info = _info_to_tex(material["normalTexture"])
		var index = tex_info.get("source")
		var image = get_image(images, index)
		if image:
			load_shader_image(image, "normalMap")
	
	# Load additional IBR Textures
	if material.has("extras"):
		_load_ibr_material(material["extras"], images)
		_load_common_ibr_textures(material["extras"], images)

func _load_common_ibr_textures(ibr : Dictionary, images : Array):
	if ibr.has("basisFunctionsUri"):
		var basis_functions_image = get_basis_functions_image()
		if basis_functions_image:
			load_shader_image(basis_functions_image, "basisFunctions")
		else:
			var basis_functions_uri = _gltf.sourceUri.get_base_dir() + "\\" + ibr["basisFunctionsUri"]
			var file = FileAccess.open(basis_functions_uri, FileAccess.READ)
			if file:
				var contents = _convert_csv(file.get_buffer(file.get_length()))
				var image = _basis_csv_to_image(contents)
				if image:
					load_shader_image(image, "basisFunctions")
	
	if ibr.has("specularWeights"):
		var weights = ibr["specularWeights"]
		_load_specular_weights(weights, images)

func _load_specular_weights(weights : Dictionary, images : Array):
	if not weights.has_all(["stride", "textures"]) or weights.get("textures").size() <= 0:
		return
	
	const shader_keys = ["weights0123", "weights4567"]
	
	# If the weights do NOT need to be converted
	if weights.get("stride") == 4 and weights.get("textures").size() >= 2:
		for i in 2:
			var tex_info = _info_to_tex(weights["textures"][i])
			var index = tex_info.get("source")
			var image = get_image(images, index)
			if image:
				load_shader_image(image, shader_keys[i])
	else:
		var uris : Array[String] = []
		for texture in weights.get("textures"):
			var index = texture["index"]
			var image_index = _gltf.state.json["textures"][index]["source"]
			var image_uri = _gltf.state.json["images"][image_index]["uri"]
			uris.push_back(_gltf.sourceUri.get_base_dir() + "\\" + image_uri)
		
		var format = weights.get("stride") + 1
		var converter = RemoteTextureCombiner.new(ResourceFetcher.new(), format, [])
		_parent.add_child(converter)
		
		converter.output_format = Image.FORMAT_RGBA8
		
		converter.combination_complete.connect(func(converter_images):
			for i in converter_images.size():
				load_shader_image(converter_images[i], shader_keys[i])
			
			converter.queue_free()
		)
		
		var images_to_convert : Array[Image] = []
		
		for i in weights.get("textures").size():
			var tex_info = _info_to_tex(weights["textures"][i])
			var index = tex_info.get("source")
			var image = get_image(images, index)
			if image:
				images_to_convert.push_back(image)
		
		converter.combine_local(images_to_convert)

func _load_ibr_material(ibr : Dictionary, images : Array):
	if ibr.has("diffuseTexture") and _shader_wants("diffuseMap"):
		var tex_info = _info_to_tex(ibr["diffuseTexture"])
		var index = tex_info.get("source")
		var image = get_image(images, index)
		if image:
			load_shader_image(image, "diffuseMap")
	
	if ibr.has("specularTexture") and _shader_wants("specularMap"):
		var tex_info = _info_to_tex(ibr["specularTexture"])
		var index = tex_info.get("source")
		var image = get_image(images, index)
		if image:
			load_shader_image(image, "specularMap")
	
	if ibr.has("roughnessTexture") and _shader_wants("roughnessMap"):
		var tex_info = _info_to_tex(ibr["roughnessTexture"])
		var index = tex_info.get("source")
		var image = get_image(images, index)
		if image:
			load_shader_image(image, "roughnessMap")
	
	if ibr.has("diffuseConstantTexture") and _shader_wants("constantMap"):
		var tex_info = _info_to_tex(ibr["diffuseConstantTexture"])
		var index = tex_info.get("source")
		var image = get_image(images, index)
		if image:
			load_shader_image(image, "constantMap")

func _load_pbr_material(pbr: Dictionary, images : Array):
	if pbr.has("baseColorTexture"):
		var tex_info = _info_to_tex(pbr["baseColorTexture"])
		var index = tex_info.get("source")
		var image = get_image(images, index)
		if image:
			load_shader_image(image, "albedoMap")
		
	if pbr.has("metallicRoughnessTexture"):
		var tex_info = _info_to_tex(pbr["metallicRoughnessTexture"])
		var index = tex_info.get("source")
		var image = get_image(images, index)
		if image:
			load_shader_image(image, "ormMap")

func get_image(images : Array, index : int) -> Image:
	if index < 0 or index >= images.size():
		return null
	
	var image_uri = images[index].get("uri")
	var file_path = _gltf.sourceUri.get_base_dir() + "\\" + image_uri
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return null
	
	return Image.load_from_file(file_path)

func get_basis_functions_image():
	var basis_functions_image_path = _gltf.sourceUri.get_base_dir() + "\\basisFunctions.png"
	var file = FileAccess.open(basis_functions_image_path, FileAccess.READ)
	
	if not file:
		return null
	
	return Image.load_from_file(basis_functions_image_path)

func _info_to_tex(texture_info: Dictionary) -> Dictionary:
	return _gltf.state.json["textures"][texture_info["index"]]

func load_shader_image(image : Image, shader_key : String):
	image.generate_mipmaps()
	image.convert(Image.FORMAT_RGBA8)
	
	var texture := ImageTexture.create_from_image(image)
	set_shader_parameter(shader_key, texture)

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

func _get_self_mesh_index(parent: Node, state: GLTFState) -> int:
	for mesh in state.meshes:
		if parent.mesh.resource_name == mesh.mesh.resource_name:
			return state.meshes.find(mesh)
	return -1

func _convert_csv(data : PackedByteArray) -> Array:
	#var data = await _fetch_url_raw(url, ["Accept: application/csv"])
	
	# Parse csv data, creating 2d array
	var file_array = Array()
	var string = data.get_string_from_utf8()
	
	for line in string.split('\n'):
		line = line.strip_edges() # Fix windows line endings
		var line_array = Array()
		
		if line == "":
			continue
		
		for entry_str in line.split(','):
			var entry = entry_str.trim_prefix(' ') # Removes leading space if the delimiter is ', '
			
			# Convert ints and floats to their respecive types
			if entry.is_valid_int():
				entry = entry.to_int()
			elif entry.is_valid_float():
				entry = entry.to_float()
			
			line_array.append(entry)
		
		file_array.append(line_array)
	
	return file_array

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
