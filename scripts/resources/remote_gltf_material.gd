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
const SHADER_STANDARD = preload("res://shaders/BasisIBR.gdshader") #TODO

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
	
	_load_common_textures(material)
	if (material.has("extras") and
	material["extras"].has_all(["basisFunctionsUri", "specularWeights"])):
		# Is IBR
		_load_ibr_common_textures(material)
		if material["extras"].has("roughnessTexture"):
			_load_specular_ibr(material)
		else:
			_load_specular_orm_ibr(material)
	else:
		# Non-IBR, use standard shader
		_load_standard_material(material)
	
	var progress = _get_load_progress()
	load_progress.emit(progress[0], progress[1])


# Loads textures common to all shader modes
func _load_common_textures(material: Dictionary):
	# Load normalMap from material
	if material.has("normalTexture"):
		_resources_loaded["normalMap"] = false
		var image_index = material["normalTexture"]["index"]
		_load_image_from_index(image_index, func(img):
			img = _process_image(img, Image.FORMAT_RG8)
			_load_shader_image(img, "normalMap")
		)


# Loads textures common to IBR shader modes
func _load_ibr_common_textures(material: Dictionary):
	# Load textures stored in material extras data
	if material.has("extras"):
		var extras = material.get("extras")
		
		if extras.has("basisFunctionsUri"):
			_resources_loaded["basisFunctions"] = false
			var uri = _format_gltf_relative_uri(extras["basisFunctionsUri"])
			_fetcher.fetch_csv_callback(uri, func(csv):
				var img = _basis_csv_to_image(csv)
				img = _process_image(img, Image.FORMAT_RGBF)
				_load_shader_image(img, "basisFunctions")
			)
		
		if extras.has("specularWeights"):
			var weights = extras["specularWeights"]
			_load_specular_weights(weights)


func _load_standard_material(material: Dictionary):
	push_error("Standard material loading is not implemented yet.") #TODO


func _load_specular_orm_ibr(material: Dictionary):
	shader = SHADER_ORM_IBR
	
	if material.has("pbrMetallicRoughness"):
		var pbr = material.get("pbrMetallicRoughness")
		
		if pbr.has("baseColorTexture"):
			_resources_loaded["albedoMap"] = false
			var image_index = pbr["baseColorTexture"]["index"]
			_load_image_from_index(image_index, func(img):
				img = _process_image(img, Image.FORMAT_RGB8)
				_load_shader_image(img, "albedoMap")
			)
		
		if pbr.has("metallicRoughnessTexture"):
			_resources_loaded["ormMap"] = false
			var image_index = pbr["metallicRoughnessTexture"]["index"]
			_load_image_from_index(image_index, func(img):
				img = _process_image(img, Image.FORMAT_RGB8)
				_load_shader_image(img, "ormMap")
			)
	
	if material.has("extras"):
		var extras = material.get("extras")
		
		if extras.has("diffuseTexture"):
			_resources_loaded["diffuseMap"] = false
			var image_index = material["diffuseTexture"]["index"]
			_load_image_from_index(image_index, func(img):
				img = _process_image(img, Image.FORMAT_RGB8)
				_load_shader_image(img, "diffuseMap")
			)

func _load_specular_ibr(material: Dictionary):
	shader = SHADER_IBR
	
	# Load diffuseMap and roughnessMap from pbr section of material
	if material.has("pbrMetallicRoughness"):
		var pbr = material.get("pbrMetallicRoughness")
		
		if pbr.has("baseColorTexture"):
			_resources_loaded["diffuseMap"] = false
			var image_index = pbr["baseColorTexture"]["index"]
			_load_image_from_index(image_index, func(img):
				img = _process_image(img, Image.FORMAT_RGB8)
				_load_shader_image(img, "diffuseMap")
			)
		
		if pbr.has("metallicRoughnessTexture"):
			_resources_loaded["roughnessMap"] = false
			var image_index = pbr["metallicRoughnessTexture"]["index"]
			_load_image_from_index(image_index, func(img):
				img = _process_image(img, Image.FORMAT_R8)
				_load_shader_image(img, "roughnessMap")
			)
	
	# Load textures stored in material extras data
	if material.has("extras"):
		var extras = material.get("extras")
		
		if extras.has("specularTexture"):
			_resources_loaded["specularMap"] = false
			var image_index = extras["specularTexture"]["index"]
			_load_image_from_index(image_index, func(img):
				img = _process_image(img, Image.FORMAT_RGB8)
				_load_shader_image(img, "specularMap")
			)
		
		if extras.has("roughnessTexture"):
			_resources_loaded["roughnessMap"] = false
			var image_index = extras["roughnessTexture"]["index"]
			_load_image_from_index(image_index, func(img):
				img = _process_image(img, Image.FORMAT_RGB8)
				_load_shader_image(img, "roughnessMap")
			)


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
			var texIdx = weights["textures"][i]["index"]
			var imgIdx = _gltf.state.json["textures"][texIdx]["source"]
			_resources_loaded[shaderKeys[i]] = false
			_load_image_from_index(imgIdx, func(img):
				img = _process_image(img, Image.FORMAT_RGBA8)
				_load_shader_image(img, shaderKeys[i])
			)
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


func _load_image_from_index(image_index: int, callback: Callable):
	var image = _gltf.state.json["images"][image_index]
	if image.has("uri"):
		var uri = image["uri"]
		if uri.begins_with("data:"):
			# Base64 embedded image
			var image_data = _decode_b64_image(uri)
			callback.call(image_data)
		else:
			# External image on server
			uri = _format_gltf_relative_uri(uri)
			_fetcher.fetch_image_callback(uri, callback)
	elif image.has("bufferView"):
		# Image in buffer
		var image_data = _decode_buffer_image(image["bufferView"])
		callback.call(image_data)
	else:
		push_error("Image at index %s could not be decoded: No uri or bufferView!" % image_index)


func _decode_buffer_image(bufferView: Dictionary) -> Image:
	push_error("Unsupported operation: buffered material images are not supported yet") #TODO
	return Image.new()


func _decode_b64_image(uri: String) -> Image:
	push_error("Unsupported operation: Base64 encoded material images are not supported yet") #TODO
	return Image.new()


func _get_texture_image_index(texture_name: String) -> int:
	if not _gltf.state.json.has("textures"):
		return -1
		
	var textures = _gltf.state.json["textures"]
	for texture in textures:
		if texture.get("name") == texture_name:
			return texture["source"]
	
	return -1


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
	
	var texture := ImageTexture.create_from_image(image)
	set_shader_parameter(shaderKey, texture)
	
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
