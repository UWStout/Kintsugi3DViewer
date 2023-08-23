# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name LocalGltfMaterial extends GltfMaterial

func _init(p_gltf : GLTFObject):
	_gltf = p_gltf

func _load_image(texture_info : Dictionary, shader_key : String):
	var tex_info = _info_to_tex(texture_info)
	var index = tex_info.get("source")
	var image = get_image(images, index)
	if image:
		_load_shader_image(image, shader_key)

func _load_basis_functions(ibr : Dictionary):
	var basis_functions_image = get_basis_functions_image()
	if basis_functions_image:
		_load_shader_image(basis_functions_image, "basisFunctions")
	else:
		var basis_functions_uri = _gltf.sourceUri.get_base_dir() + "\\" + ibr["basisFunctionsUri"]
		var file = FileAccess.open(basis_functions_uri, FileAccess.READ)
		if file:
			var contents = _convert_csv(file.get_buffer(file.get_length()))
			var image = _basis_csv_to_image(contents)
			if image:
				_load_shader_image(image, "basisFunctions")

func _load_specular_weights(weights : Dictionary):
	if not weights.has_all(["stride", "textures"]) or weights.get("textures").size() <= 0:
		return
	
	const shader_keys = ["weights0123", "weights4567"]
	
	# If the weights do NOT need to be converted
	if weights.get("stride") == 4 and weights.get("textures").size() >= 2:
		for i in 2:
			var tex_info = _info_to_tex(weights["textures"][i])
			var index = tex_info.get("source")
			var image = get_image(images, index)
			if image:
				_load_shader_image(image, shader_keys[i])
	else:
		var uris : Array[String] = []
		for texture in weights.get("textures"):
			var index = texture["index"]
			var image_index = _gltf.state.json["textures"][index]["source"]
			var image_uri = _gltf.state.json["images"][image_index]["uri"]
			uris.push_back(_gltf.sourceUri.get_base_dir() + "\\" + image_uri)
		
		var format = weights.get("stride") + 1
		var converter = RemoteTextureCombiner.new(ResourceFetcher.new(), format, [])
		_parent.add_child(converter)
		
		converter.output_format = Image.FORMAT_RGBA8
		
		converter.combination_complete.connect(func(converter_images):
			for i in converter_images.size():
				_load_shader_image(converter_images[i], shader_keys[i])
			
			converter.queue_free()
		)
		
		var images_to_convert : Array[Image] = []
		
		for i in weights.get("textures").size():
			var tex_info = _info_to_tex(weights["textures"][i])
			var index = tex_info.get("source")
			var image = get_image(images, index)
			if image:
				images_to_convert.push_back(image)
		
		converter.combine_local(images_to_convert)

func get_image(images : Array, index : int) -> Image:
	if index < 0 or index >= images.size():
		return null
	
	var image_uri = images[index].get("uri")
	var file_path = _gltf.sourceUri.get_base_dir() + "\\" + image_uri
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return null
	
	return Image.load_from_file(file_path)

func get_basis_functions_image():
	var basis_functions_image_path = _gltf.sourceUri.get_base_dir() + "\\basisFunctions.png"
	var file = FileAccess.open(basis_functions_image_path, FileAccess.READ)
	
	if not file:
		return null
	
	return Image.load_from_file(basis_functions_image_path)

func _convert_csv(data : PackedByteArray) -> Array:
	#var data = await _fetch_url_raw(url, ["Accept: application/csv"])
	
	# Parse csv data, creating 2d array
	var file_array = Array()
	var string = data.get_string_from_utf8()
	
	for line in string.split('\n'):
		line = line.strip_edges() # Fix windows line endings
		var line_array = Array()
		
		if line == "":
			continue
		
		for entry_str in line.split(','):
			var entry = entry_str.trim_prefix(' ') # Removes leading space if the delimiter is ', '
			
			# Convert ints and floats to their respecive types
			if entry.is_valid_int():
				entry = entry.to_int()
			elif entry.is_valid_float():
				entry = entry.to_float()
			
			line_array.append(entry)
		
		file_array.append(line_array)
	
	return file_array
