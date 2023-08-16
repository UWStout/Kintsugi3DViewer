# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends ResourceFetcherChain

# Overload _init from ResourceFetcherChain to have 0 parameters
func _init():
	pass


# Set up the Resource Fetcher chain at runtime
# TODO: Read configurations to disable/enable cache and optimize the resource
# pipeline for the current device at runtime
func _ready():
	var http_fetcher = preload("res://scripts/resources/http_json_resource_fetcher.gd").new()
	http_fetcher.name = "HTTP Fetcher"
	var cache_fetcher = CachedResourceFetcher.new(http_fetcher)
	cache_fetcher.name = "Cache Fetcher"
	_child_fetcher = cache_fetcher
	add_child(http_fetcher)
	add_child(cache_fetcher)
