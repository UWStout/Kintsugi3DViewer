# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends ResourceFetcher
class_name ResourceFetcherChain

var _child_fetcher: ResourceFetcher

func _init(p_child_fetcher: ResourceFetcher):
	_child_fetcher = p_child_fetcher


func get_subfetcher() -> ResourceFetcher:
	return _child_fetcher


func get_fetcher_by_type(type: Variant) -> ResourceFetcher:
	if is_instance_of(self, type):
		return self
	else:
		if is_instance_valid(_child_fetcher):
			return _child_fetcher.get_fetcher_by_type(type)
		else:
			return null


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
