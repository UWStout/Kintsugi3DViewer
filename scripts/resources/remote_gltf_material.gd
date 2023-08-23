# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends GltfMaterial
class_name RemoteGltfMaterial

var _fetcher: ResourceFetcher

func _init(p_fetcher: ResourceFetcher, p_gltf: GLTFObject):
	_fetcher = p_fetcher
	_gltf = p_gltf

func _load_image(texture_info : Dictionary, shader_key : String):
	_start_tex_load(_info_to_tex(texture_info), shader_key)

func _load_basis_functions(ibr : Dictionary):
	var imported = CacheManager.import_png(_gltf.sourceUri.get_base_dir(), "basisFunctions")
	if not imported == null:
		_load_shader_image(imported, "basisFunctions")
	else:
		var uri = _format_gltf_relative_uri(ibr["basisFunctionsUri"])
		_fetcher.fetch_csv_callback(uri, func(csv):
			var img = _basis_csv_to_image(csv)
			img.convert(Image.FORMAT_RGBF)
			_load_shader_image(img, "basisFunctions")
		)

func _load_specular_weights(weights: Dictionary):
	# Validate that specular weights object has required properties
	if ((not weights.has_all(["stride", "textures"])) or 
	weights.get("textures").size() <= 0):
		push_error("Malformed specular weights extra data block: %s" % weights)
		return
	
	const shaderKeys = ["weights0123", "weights4567"]
	
	if weights.get("stride") == 4 and weights.get("textures").size() >= 2:
		# No conversion to RGBA is needed, Load upper and lower weights directly
		for i in 2:
			_start_tex_load(_info_to_tex(weights["textures"][i]), shaderKeys[i])
	else:
		var uris: Array[String] = []
		for texture in weights.get("textures"):
			var texIdx = texture["index"]
			var imgIdx = _gltf.state.json["textures"][texIdx]["source"]
			var uri = _gltf.state.json["images"][imgIdx]["uri"]
			uris.append(_format_gltf_relative_uri(uri))
		
		var format = weights.get("stride") + 1
		var converter = RemoteTextureCombiner.new(_fetcher, format, uris)
		_parent.add_child(converter)
		
		converter.output_format = Image.FORMAT_RGBA8
		
		converter.combination_complete.connect(func(images):
			for i in images.size():
				_load_shader_image(images[i], shaderKeys[i])
			converter.queue_free()
		)
		
		converter.combine()

func _start_tex_load(texture: Dictionary, key: String):
	print("Starting texture load for " + key)
	_resources_loaded[key] = false
	var texture_loader = RemoteGltfTexture.new(self, texture, key)
	_parent.add_child(texture_loader)
	texture_loader.texture_loaded.connect(_texture_loader_completion)
	texture_loader.load()

func _texture_loader_completion(key: String):
	_resources_loaded[key] = true
	_update_progress()
