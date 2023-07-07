extends ResourceFetcher
class_name ResourceFetcherChain

var _child_fetcher: ResourceFetcher

func _init(p_child_fetcher: ResourceFetcher):
	_child_fetcher = p_child_fetcher


# By default, simply pass requests through to child fetcher
func fetch_artifacts() -> Array[ArtifactData]:
	return await _child_fetcher.fetch_artifacts()


func force_fetch_artifacts() -> Array[ArtifactData]:
	return await _child_fetcher.force_fetch_artifacts()


func fetch_gltf(artifact: ArtifactData) -> GLTFObject:
	return await _child_fetcher.fetch_gltf(artifact)


func force_fetch_gltf(artifact: ArtifactData) -> GLTFObject:
	return await _child_fetcher.force_fetch_gltf(artifact)


func fetch_buffer(uri: String) -> PackedByteArray:
	return await _child_fetcher.fetch_buffer(uri)


func force_fetch_buffer(uri: String) -> PackedByteArray:
	return await _child_fetcher.force_fetch_buffer(uri)


func fetch_image(uri: String) -> Image:
	return await _child_fetcher.fetch_image(uri)


func force_fetch_image(uri: String) -> Image:
	return await _child_fetcher.force_fetch_image(uri)


func fetch_voyager(uri: String) -> Dictionary:
	return await _child_fetcher.fetch_voyager(uri)


func force_fetch_voyager(uri: String) -> Dictionary:
	return await _child_fetcher.force_fetch_voyager(uri)


func fetch_json(uri: String) -> Dictionary:
	return await _child_fetcher.fetch_json(uri)


func force_fetch_json(uri: String) -> Dictionary:
	return await _child_fetcher.force_fetch_json(uri)


func fetch_csv(uri: String) -> Array:
	return await _child_fetcher.fetch_csv(uri)


func force_fetch_csv(uri: String) -> Array:
	return await _child_fetcher.force_fetch_csv(uri)
