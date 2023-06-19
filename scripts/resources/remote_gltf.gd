extends Node3D

#TODO: Debug
@export var artifactGltfUrl: String
@export var shader: Shader
@export var fetcher: ResourceFetcher
var artifact: ArtifactData

func _ready():
	artifact = ArtifactData.new()
	artifact.gltfUrl = artifactGltfUrl
	load_artifact()

func load_artifact():
	print("Loading artifact from %s" % artifact.gltfUrl)
	var obj = await fetcher.fetch_gltf(artifact)
	var scene = obj.generate_scene()
	add_child(scene)
	var mesh = scene.get_child(0, true)
	var mat = RemoteGltfMaterial.new(fetcher, obj)
	mat.shader = shader
	mesh.set_surface_override_material(0, mat)
	mat.load(mesh)
