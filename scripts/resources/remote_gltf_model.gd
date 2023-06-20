extends Node3D
class_name RemoteGltfModel

@export var artifactGltfUrl: String

@export var shader: Shader = preload("res://BasisIBR.gdshader")
@export var fetcher: ResourceFetcher

var artifact: ArtifactData = null

func _ready():
	# Ensure the resource fetcher is avaliable
	if not is_instance_valid(fetcher):
		fetcher = %Fetcher
		if not is_instance_valid(fetcher):
			push_error("Remote glTF loader at node %s could not find a valid resource fetcher!" % get_path())
			return
	
	# If a URL is provided, override the artifact and load on ready. Used for testing.
	if not artifactGltfUrl.is_empty():
		artifact = ArtifactData.new()
		artifact.gltfUrl = artifactGltfUrl
		load_artifact()


func load_artifact():
	var obj = await fetcher.fetch_gltf(artifact)
	var scene = obj.generate_scene()
	add_child(scene)
	var mesh = scene.get_child(0, true)
	var mat = RemoteGltfMaterial.new(fetcher, obj)
	mat.shader = shader
	mesh.set_surface_override_material(0, mat)
	mat.load(mesh)


static func create(p_artifact: ArtifactData) -> RemoteGltfModel:
	var model = RemoteGltfModel.new()
	model.artifact = p_artifact
	return model
