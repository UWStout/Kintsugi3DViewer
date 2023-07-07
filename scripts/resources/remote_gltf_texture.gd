extends Node
class_name RemoteGltfTexture

signal load_complete
signal load_progress(complete: int, total: int)

var _fetcher: ResourceFetcher
var _gltf: GLTFObject
var _texture: Dictionary

func _init(p_fetcher: ResourceFetcher, p_gltf: GLTFObject, p_texture: Dictionary):
	_fetcher = p_fetcher
	_gltf = p_gltf
	_texture = p_texture


func load(material: ShaderMaterial, parameterKey: String):
	pass

