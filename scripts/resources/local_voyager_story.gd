class_name LocalVoyagerStory extends GltfModel

var light_nodes: Array[Node3D] = []

func _init(p_artifact: ArtifactData):
	artifact = p_artifact
	is_local = true
	
func load_artifact():
	#print("=== load_artifact called, instance: ", self)
	var voyager_json_path = artifact.voyagerUri
	if not FileAccess.file_exists(voyager_json_path):
		push_error("Voyager scene file not found: %s" % voyager_json_path)
		return
		
	var file = FileAccess.open(voyager_json_path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		push_error("Failed to parse local Voyager scene: %s" % voyager_json_path)
		return
		
	JsonReader.update_with_json(parsed)
	VoyagerLoader._load_voyager(self, false, voyager_json_path)
