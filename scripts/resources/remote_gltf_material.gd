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
	
	print(material)
	if material.has("pbrMetallicRoughness"):
		var pbr = material.get("pbrMetallicRoughness")
		
		if pbr.has("baseColorTexture"):
			var uri = _gltf.state.json.get("images")[pbr["baseColorTexture"]["index"]]["uri"]
			uri = _format_gltf_relative_uri(uri)
			_fetcher.fetch_image_callback(uri, _load_diffuse)


func _get_self_mesh_index(parent: Node, state: GLTFState) -> int:
	for mesh in state.meshes:
		if parent.mesh.resource_name == mesh.mesh.resource_name:
			return state.meshes.find(mesh)
	return -1


func _format_gltf_relative_uri(uri: String) -> String:
	var folder = _gltf.sourceUri.get_base_dir()
	return folder.path_join(uri)


func _load_diffuse(image: Image):
	print("Diffuse loaded")
	image.generate_mipmaps()
	image.convert(Image.FORMAT_RGB8)
	set_shader_parameter("diffuseMap", ImageTexture.create_from_image(image))
