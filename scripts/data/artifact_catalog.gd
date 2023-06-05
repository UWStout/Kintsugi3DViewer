extends Node

signal artifacts_loaded(artifacts: Array[ArtifactData])

var data_source_url: String = "https://pastebin.com/raw/FMi7rxHd" #TODO: Make configurable

var raw_data: Variant
var artifacts: Array[ArtifactData]

func _ready():
	_load_artifacts_from_remote_url(data_source_url)
	await self.artifacts_loaded
	print("Finished initial remote artifacts load!")
	print("Loaded artifacts: %s" % [artifacts])

func load_artifacts():
	_load_artifacts_from_remote_url(data_source_url)

func get_artifacts() -> Array[ArtifactData]:
	return artifacts

func _parse_artifacts():
	if raw_data.has("artifacts"):
		artifacts.clear()
		for artifact_raw in raw_data.get("artifacts"):
			var artifact = ArtifactData.from_dict(artifact_raw)
			artifacts.append(artifact)
	else:
		push_error("Failed to parse artifact listing!")

func _load_artifacts_from_remote_url(url: String):
	var req = HTTPRequest.new()
	add_child(req)
	
	req.request_completed.connect(
		func(result, response_code, headers, body):
			if response_code != 200:
				push_error("The server returned a %s error attempting to fetch remote artifact listing." % response_code)
			raw_data = JSON.parse_string(body.get_string_from_utf8())
			_parse_artifacts()
			artifacts_loaded.emit(artifacts)
			req.queue_free()
	)
	
	var error = req.request(url)
	if error != OK:
		push_error("An error occurred attempting to fetch remote artifact listing.")
