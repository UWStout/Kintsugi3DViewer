extends GltfModel
class_name RemoteVoyagerStory

@export var fetcher: ResourceFetcher

func _init(p_artifact: ArtifactData):
	artifact = p_artifact

func _ready():
	# Ensure the resource fetcher is avaliable
	if not is_instance_valid(fetcher):
		fetcher = GlobalFetcher
		if not is_instance_valid(fetcher):
			push_error("Remote Voyager Story loader at node %s could not find a valid resource fetcher!" % get_path())
			return

func load_artifact():
	var voyager_data = await fetcher.fetch_voyager(artifact.voyagerUri)
	JsonReader.update_with_json(voyager_data)
	VoyagerLoader._load_voyager(self, true, artifact.gltfUri)
