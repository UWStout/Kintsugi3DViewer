extends Node3D
class_name RemoteVoyagerStory

signal load_completed
signal load_progress(estimation: float)

@export var fetcher: ResourceFetcher

var artifact: ArtifactData

func _init(p_artifact: ArtifactData):
	artifact = p_artifact


func _ready():
	# Ensure the resource fetcher is avaliable
	if not is_instance_valid(fetcher):
		fetcher = GlobalFetcher
		if not is_instance_valid(fetcher):
			push_error("Remote Voyager Story loader at node %s could not find a valid resource fetcher!" % get_path())
			return


func load_scene():
	# TODO: Implement loading voyager story artifact
	var voyager_data = await fetcher.fetch_voyager(artifact.voyagerUri)
	print(voyager_data.keys())
	var voyagergltfdata = ArtifactData.new()
	voyagergltfdata.gltfUri = artifact.gltfUri.get_base_dir() +"/"+ voyager_data["models"][0]["derivatives"][0]["assets"][0]["uri"]
	var model = RemoteGltfModel.create(voyagergltfdata)
	add_child(model)
	model.load_artifact()
	pass
