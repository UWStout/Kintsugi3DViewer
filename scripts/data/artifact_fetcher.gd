extends Node
class_name ArtifactFetcher

signal artifacts_refreshed(artifacts: Array[ArtifactData])

func fetch_artifacts(completed: Callable) -> Array[ArtifactData]:
	push_error("Abstract function fetch_artifacts() called on ArtifactFetcher!")
	return Array()

func force_fetch_artifacts(completed: Callable) -> Array[ArtifactData]:
	push_error("Abstract function force_fetch_artifacts() called on ArtifactFetcher!")
	return Array()

func fetch_gltf(artifact: ArtifactData, completed: Callable) -> GLTFDocument:
	push_error("Abstract function fetch_gltf() called on ArtifactFetcher!")
	return GLTFDocument.new()

func force_fetch_gltf(artifact: ArtifactData, completed: Callable) -> GLTFDocument:
	push_error("Abstract function force_fetch_gltf() called on ArtifactFetcher!")
	return GLTFDocument.new()

func fetch_buffer(uri, completed: Callable) -> PackedByteArray:
	push_error("Abstract function fetch_buffer() called on ArtifactFetcher!")
	return []

func force_fetch_buffer(uri, completed: Callable) -> PackedByteArray:
	push_error("Abstract function force_fetch_buffer() called on ArtifactFetcher!")
	return []

func fetch_image(uri, completed: Callable) -> Image:
	push_error("Abstract function fetch_image() called on ArtifactFetcher!")
	return Image.new()

func force_fetch_image(uri, completed: Callable) -> Image:
	push_error("Abstract function force_fetch_image() called on ArtifactFetcher!")
	return Image.new()

func fetch_voyager(uri, completed: Callable) -> Dictionary:
	push_error("Abstract function fetch_voyager() called on ArtifactFetcher!")
	return {}

func force_fetch_voyager(uri, completed: Callable) -> Dictionary:
	push_error("Abstract function force_fetch_voyager() called on ArtifactFetcher!")
	return {}
