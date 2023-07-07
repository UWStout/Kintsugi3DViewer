extends RefCounted
class_name ArtifactData

var name: String
var iconUri: String
var gltfUri: String
var voyagerUri: String

static func from_dict(data: Dictionary) -> ArtifactData:
	var out_data = ArtifactData.new()
	
	if data.has("name"):
		out_data.name = data.get("name")
	
	if data.has("iconUri"):
		out_data.iconUri = data.get("iconUri")
	
	if data.has("gltfUrl"): #Backwards compatability with Url instead of Uri
		out_data.gltfUri = data.get("gltfUrl")
	
	if data.has("gltfUri"):
		out_data.gltfUri = data.get("gltfUri")
	
	if data.has("voyagerUri"):
		out_data.voyagerUri = data.get("voyagerUri")
	
	return out_data

func _to_string() -> String:
	return name
