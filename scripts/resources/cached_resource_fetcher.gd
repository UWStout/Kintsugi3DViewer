extends ResourceFetcherChain
class_name CachedResourceFetcher

func fetch_gltf(artifact: ArtifactData) -> GLTFObject:
	return await force_fetch_gltf(artifact) #TODO


func fetch_image(uri: String) -> Image:
	return await force_fetch_image(uri) #TODO


func fetch_json(uri: String) -> Dictionary:
	return await force_fetch_json(uri) #TODO


func fetch_csv(uri: String) -> Array:
	return await force_fetch_csv(uri) #TODO
