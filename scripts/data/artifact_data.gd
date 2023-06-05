extends RefCounted
class_name ArtifactData

var name: String
var iconUrl: String
var gltfUrl: String

static func from_dict(data: Dictionary) -> ArtifactData:
	var out_data = ArtifactData.new()
	if data.has("name"):
		out_data.name = data.get("name")
	if data.has("iconUrl"):
		out_data.iconUrl = data.get("iconUrl")
	if data.has("gltfUrl"):
		out_data.gltfUrl = data.get("gltfUrl")
	return out_data

func _to_string() -> String:
	return name
