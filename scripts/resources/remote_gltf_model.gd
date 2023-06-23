extends Node3D
class_name RemoteGltfModel

signal load_completed
signal load_progress(estimation: float)

@export var artifactGltfUrl: String

@export var shader: Shader = preload("res://BasisIBR.gdshader")
@export var fetcher: ResourceFetcher

var artifact: ArtifactData = null
var mat_loader: RemoteGltfMaterial
var obj: GLTFObject

func _ready():
	# Ensure the resource fetcher is avaliable
	if not is_instance_valid(fetcher):
		fetcher = GlobalFetcher
		if not is_instance_valid(fetcher):
			push_error("Remote glTF loader at node %s could not find a valid resource fetcher!" % get_path())
			return
	
	# If a URL is provided, override the artifact and load on ready. Used for testing.
	if not artifactGltfUrl.is_empty():
		artifact = ArtifactData.new()
		artifact.gltfUrl = artifactGltfUrl
		load_artifact()


func load_artifact():
	obj = await fetcher.fetch_gltf(artifact)
	var scene = obj.generate_scene()
	add_child(scene)
	
	# TODO: Support multiple materials by scanning entire subtree/glTF data to find meshes
	# instead of just grabbing the first child node and hoping its a mesh!
	var mesh = scene.get_child(0, true)
	mat_loader = RemoteGltfMaterial.new(fetcher, obj)
	
	mat_loader.load_complete.connect(_on_material_load_complete)
	mat_loader.load_progress.connect(_on_material_load_progress)
	
	mat_loader.shader = shader
	mesh.set_surface_override_material(0, mat_loader)
	mat_loader.load(mesh)


func _on_material_load_complete():
	load_completed.emit()


func _on_material_load_progress(complete: int, total: int):
	total += 1
	if obj != null:
		complete += 1
		
	var progress = float(complete) / (total)
	load_progress.emit(progress)


static func create(p_artifact: ArtifactData) -> RemoteGltfModel:
	var model = RemoteGltfModel.new()
	model.artifact = p_artifact
	return model
