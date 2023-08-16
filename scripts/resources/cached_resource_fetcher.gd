# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends ResourceFetcherChain
class_name CachedResourceFetcher

var _cache #TODO: Strong type

func _ready():
	_cache = CacheManager


func is_gltf_cached(uri: String) -> bool:
	return false


func is_image_cached(uri: String) -> bool:
	var dir: String = uri.get_base_dir()
	var file: String = uri.get_file().trim_suffix(uri.get_extension()).rstrip('.')
	return _cache.png_cached(dir, file)


func fetch_gltf(artifact: ArtifactData) -> GLTFObject:
	print("glTF requested from cache: %s" % artifact)
	return await force_fetch_gltf(artifact) #TODO


func fetch_image(uri: String) -> Image:
	var dir: String = uri.get_base_dir()
	var file: String = uri.get_file().trim_suffix(uri.get_extension()).rstrip('.')
	
	var imported = _cache.import_png(dir, file)
	if imported != null:
		print("Found uri in cache: %s" % uri)
		return imported
	else:
		var fetched = await _child_fetcher.fetch_image(uri)
		_cache.export_png(dir, file, fetched)
		return fetched


func fetch_json(uri: String) -> Dictionary:
	return await force_fetch_json(uri) #TODO


func fetch_csv(uri: String) -> Array:
	return await force_fetch_csv(uri) #TODO
