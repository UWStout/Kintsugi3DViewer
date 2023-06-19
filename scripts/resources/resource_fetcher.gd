extends Node
class_name ResourceFetcher

signal artifacts_refreshed(artifacts: Array[ArtifactData])

func fetch_artifacts() -> Array[ArtifactData]:
	return await force_fetch_artifacts()

func force_fetch_artifacts() -> Array[ArtifactData]:
	push_error("Abstract function force_fetch_artifacts() called on ArtifactFetcher!")
	return Array()

func fetch_gltf(artifact: ArtifactData) -> GLTFObject:
	return await force_fetch_gltf(artifact)

func force_fetch_gltf(artifact: ArtifactData) -> GLTFObject:
	push_error("Abstract function force_fetch_gltf() called on ArtifactFetcher!")
	return GLTFObject.new()

func fetch_buffer(uri: String) -> PackedByteArray:
	return await force_fetch_buffer(uri)

func force_fetch_buffer(uri: String) -> PackedByteArray:
	push_error("Abstract function force_fetch_buffer() called on ArtifactFetcher!")
	return []

func fetch_image(uri: String) -> Image:
	return await force_fetch_image(uri)

func force_fetch_image(uri: String) -> Image:
	push_error("Abstract function force_fetch_image() called on ArtifactFetcher!")
	return Image.new()

func fetch_voyager(uri: String) -> Dictionary:
	return await force_fetch_voyager(uri)

func force_fetch_voyager(uri: String) -> Dictionary:
	push_error("Abstract function force_fetch_voyager() called on ArtifactFetcher!")
	return {}

func fetch_json(uri: String) -> Dictionary:
	return await force_fetch_json(uri)

func force_fetch_json(uri: String) -> Dictionary:
	push_error("Abstract function force_fetch_json() called on ArtifactFetcher!")
	return {}

func fetch_csv(uri: String) -> Array:
	return await force_fetch_csv(uri)

func force_fetch_csv(uri: String) -> Array:
	push_error("Abstract function force_fetch_csv() called on ArtifactFetcher!")
	return []

# Callback versions of above functions for convienence
func fetch_artifacts_callback(completed: Callable):
	var result = await fetch_artifacts()
	completed.call(result)

func force_fetch_artifacts_callback(completed: Callable):
	var result = await force_fetch_artifacts()
	completed.call(result)

func fetch_gltf_callback(artifact: ArtifactData, completed: Callable):
	var result = await fetch_gltf(artifact)
	completed.call(result)

func force_fetch_gltf_callback(artifact: ArtifactData, completed: Callable):
	var result = await force_fetch_gltf(artifact)
	completed.call(result)

func fetch_buffer_callback(uri:String, completed: Callable):
	var result = await fetch_buffer(uri)
	completed.call(result)

func force_fetch_buffer_callback(uri: String, completed: Callable):
	var result = await force_fetch_buffer(uri)
	completed.call(result)

func fetch_image_callback(uri: String, completed: Callable):
	var result = await fetch_image(uri)
	completed.call(result)

func force_fetch_image_callback(uri: String, completed: Callable):
	var result = await force_fetch_image(uri)
	completed.call(result)

func fetch_voyager_callback(uri: String, completed: Callable):
	var result = await fetch_voyager(uri)
	completed.call(result)

func force_fetch_voyager_callback(uri: String, completed: Callable):
	var result = await force_fetch_voyager(uri)
	completed.call(result)

func fetch_json_callback(uri: String, completed: Callable):
	var result = await fetch_json(uri)
	completed.call(result)

func force_fetch_json_callback(uri: String, completed: Callable):
	var result = await force_fetch_json(uri)
	completed.call(result)

func fetch_csv_callback(uri: String, completed: Callable):
	var result = await fetch_csv(uri)
	completed.call(result)

func force_fetch_csv_callback(uri: String, completed: Callable):
	var result = await force_fetch_csv(uri)
	completed.call(result)
