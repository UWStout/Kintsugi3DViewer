extends RefCounted
class_name ArtifactData

var name: String
var iconUrl: String
#TODO: Fields for GLTF loading

static func from_dict(data: Dictionary) -> ArtifactData:
	var out_data = ArtifactData.new()
	out_data.name = data.get("name")
	out_data.iconUrl = data.get("iconUrl")
	return out_data

func _to_string() -> String:
	return name
