extends ShaderMaterial
class_name RemoteGltfMaterial

var _fetcher: ResourceFetcher
var _gltf: GLTFObject

func _init(p_fetcher: ResourceFetcher, p_gltf: GLTFObject):
	_fetcher = p_fetcher
	_gltf = p_gltf


func load(parent: Node):
	if not _gltf.state.json.has("materials"):
		return
	
	var index = _get_self_mesh_index(parent, _gltf.state)
	if index < 0:
		return
	
	var mesh = _gltf.state.json.get("meshes")[index]
	var material_index = mesh.get("primitives")[0].get("material")
	var material = _gltf.state.json.get("materials")[material_index]
	
	# Load diffuseMap and roughnessMap from pbr section of material
	if material.has("pbrMetallicRoughness"):
		var pbr = material.get("pbrMetallicRoughness")
		
		if pbr.has("baseColorTexture"):
			var image_index = pbr["baseColorTexture"]["index"]
			_load_image_from_index(image_index, func(img):
				img = _process_image(img, Image.FORMAT_RGB8)
				_load_shader_image(img, "diffuseMap")
			)
		
		if pbr.has("metallicRoughnessTexture"):
			var image_index = pbr["metallicRoughnessTexture"]["index"]
			_load_image_from_index(image_index, func(img):
				img = _process_image(img, Image.FORMAT_R8)
				_load_shader_image(img, "roughnessMap")
			)
	
	# Load normalMap from material
	if material.has("normalTexture"):
		var image_index = material["normalTexture"]["index"]
		_load_image_from_index(image_index, func(img):
			img = _process_image(img, Image.FORMAT_RG8)
			_load_shader_image(img, "normalMap")
		)
	
	# Hacky textures that arent a part of the material
	var specular_index = _get_texture_image_index("specular")
	if specular_index >= 0:
		_load_image_from_index(specular_index, func(img):
			img = _process_image(img, Image.FORMAT_RGB8)
			_load_shader_image(img, "specularMap")
		)
	
	# Load the combined weight images
	var weight03_index = _get_texture_image_index("weight00-03")
	if weight03_index >= 0:
		_load_image_from_index(weight03_index, func(img):
			img = _process_image(img, Image.FORMAT_RGBA8)
			_load_shader_image(img, "weights0123")
		)
	
	var weight07_index = _get_texture_image_index("weight00-07")
	if weight07_index >= 0:
		_load_image_from_index(weight07_index, func(img):
			img = _process_image(img, Image.FORMAT_RGBA8)
			_load_shader_image(img, "weights4567")
		)
	
	#TODO: Temporary!!!
	_fetcher.fetch_image_callback("guan-yu/weights00-03.png", func(img):
		print("Loaded lower weights")
		img = _process_image(img, Image.FORMAT_RGBA8)
		_load_shader_image(img, "weights0123")
	)
	_fetcher.fetch_image_callback("guan-yu/weights04-07.png", func(img):
		print("Loaded upper weights")
		img = _process_image(img, Image.FORMAT_RGBA8)
		_load_shader_image(img, "weights4567")
	)
	# TODO: How will this uri be included in the gltf? Just as another image?
	var csv = await _fetcher._fetch_url_csv(_fetcher._format_relative_url("guan-yu/basisFunctions.csv"))
	print("loading basis functions")
	var img = _basis_csv_to_image(csv)
	img = _process_image(img, Image.FORMAT_RGBF)
	_load_shader_image(img, "basisFunctions")


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
	var texture := ImageTexture.create_from_image(image)
	set_shader_parameter(shaderKey, texture)


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


func _combine_color_channels(in_images: Array[Image], out_format: Image.Format) -> Array[Image]:
	var out_images: Array[Image] = Array()
	
	# Pull parameters from the first image
	# Assumes all images are the same size, format and stride
	var channels = _get_pixel_stride(in_images[0].get_format())
	var width = in_images[0].get_width()
	var height = in_images[0].get_height()
	var stride = _get_pixel_stride(out_format)
	
	for index in range(0, (channels + (stride - 1)) / stride):
		var image = Image.create(width, height, false, out_format)
		
		#TODO: Finish this function
		
		out_images.append(image)
	
	return out_images


func _get_pixel_stride(format: Image.Format) -> int:
	if format >= Image.FORMAT_R8 and format <= Image.FORMAT_RGBA8:
		return format - (Image.FORMAT_R8 - 1)
	elif format >= Image.FORMAT_RF and format <= Image.FORMAT_RGBAF:
		return format - (Image.FORMAT_RF - 1)
	elif format >= Image.FORMAT_RH and format <= Image.FORMAT_RGBAH:
		return format - (Image.FORMAT_RH - 1)
	else:
		return 0
