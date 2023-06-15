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
	
	#TODO: Debug prints
	print(material)
	print(_gltf.state.json["textures"])
	if material.has("pbrMetallicRoughness"):
		var pbr = material.get("pbrMetallicRoughness")
		
		if pbr.has("baseColorTexture"):
			var image_index = pbr["baseColorTexture"]["index"]
			_load_image(image_index, _load_diffuse)
		
		if pbr.has("metallicRoughnessTexture"):
			var image_index = pbr["metallicRoughnessTexture"]["index"]
			_load_image(image_index, _load_roughness)
	
	if material.has("normalTexture"):
		var image_index = material["normalTexture"]["index"]
		_load_image(image_index, _load_normal)
	
	# Hacky textures that arent a part of the material
	var specular_index = _get_texture_image_index("specular")
	if specular_index >= 0:
		_load_image(specular_index, _load_specular)


func _load_image(image_index: int, callback: Callable):
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


#TODO: clean this up
func _load_diffuse(image: Image):
	print("loaded diffuse")
	image.generate_mipmaps()
	image.convert(Image.FORMAT_RGB8)
	set_shader_parameter("diffuseMap", ImageTexture.create_from_image(image))


func _load_normal(image: Image):
	print("loaded normal")
	image.generate_mipmaps()
	image.convert(Image.FORMAT_RG8)
	set_shader_parameter("normalMap", ImageTexture.create_from_image(image))


func _load_specular(image: Image):
	print("loaded specular")
	image.generate_mipmaps()
	image.convert(Image.FORMAT_RGB8)
	set_shader_parameter("specularMap", ImageTexture.create_from_image(image))


func _load_roughness(image: Image):
	print("loaded roughness")
	image.generate_mipmaps()
	image.convert(Image.FORMAT_R8)
	set_shader_parameter("roughnessMap", ImageTexture.create_from_image(image))
