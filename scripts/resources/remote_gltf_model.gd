extends Node3D
class_name RemoteGltfModel

signal load_completed
signal load_progress(estimation: float)

@export var artifactGltfUrl: String

@export var fetcher: ResourceFetcher

var artifact: ArtifactData = null
var mat_loader: RemoteGltfMaterial
var obj: GLTFObject
var aabb : AABB

var load_finished : bool = false

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
		artifact.gltfUri = artifactGltfUrl
		load_artifact()


func load_artifact() -> int:
	var imported = null
	
	var dir_name = artifact.gltfUri.get_base_dir()
	var file_name = artifact.gltfUri.trim_prefix(dir_name + "/")
	file_name = file_name.trim_suffix(".glb")
	file_name = file_name.trim_suffix(".gltf")

	imported = CacheManager.import_gltf(dir_name, file_name)
	
	if not imported == null:
		obj = GLTFObject.new()
		obj.document = imported.doc
		obj.state = imported.state
		obj.sourceUri = artifact.gltfUri
	elif not Preferences.read_pref("offline mode"):
		obj = await fetcher.fetch_gltf(artifact)
		print("fetched!")
	
	if obj == null:
		print("COULDN'T FETCH GLTF")
		return -1
	
	# if the import failed, then there isn't a GLTF file exported
	# to the cache, so we should export this one
	if imported == null:
		print(obj.sourceUri)
		CacheManager.export_gltf(dir_name, file_name, obj.document, obj.state.duplicate())
		CacheManager.export_artifact_data(dir_name, artifact)
	
	var scene = obj.generate_scene()
	
	if scene == null:
		push_error("Failed to load glTF into scene!")
		return -1
	
	add_child(scene)
	
	# TODO: Support multiple materials by scanning entire subtree/glTF data to find meshes
	# instead of just grabbing the first child node and hoping its a mesh!
	var mesh = scene.get_child(0, true)
	
	if mesh.get_aabb() != null:
		aabb = mesh.get_aabb()
	else:
		aabb = AABB()
	
	mat_loader = RemoteGltfMaterial.new(fetcher, obj)
	
	mat_loader.load_complete.connect(_on_material_load_complete)
	mat_loader.load_progress.connect(_on_material_load_progress)
	
	mesh.set_surface_override_material(0, mat_loader)
	mat_loader.load(mesh)
	
	return 1


func _on_material_load_complete():
	load_completed.emit()
	load_finished = true


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
