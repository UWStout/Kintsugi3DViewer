# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends RefCounted
class_name GLTFObject

var document: GLTFDocument
var state: GLTFState
var sourceUri: String


func generate_scene() -> Node:
	if document == null or state == null:
		return null
	return document.generate_scene(state)

static func from_buffer(buffer : PackedByteArray) -> GLTFObject:
	var document = GLTFDocument.new()
	var state = GLTFState.new()
	
	# 0x20 is used for flags to disable loading of textures and images, as
	# the godot glTF loader will by default try to find external resources during
	# the initial load process and is not euqipped to handle http resources, thus
	# causing the load to fail outright. See modules/gltf/gltf_document.cpp@69,7318,7364
	var gltf_error = document.append_from_buffer(buffer, "", state, 0x20)

	if gltf_error:
		push_error("An error occured parsing glTF data! Error code: %s" % gltf_error)
		return null
	
	var uri_found = false
	var bufferView_found = false
	
	if state.json != null and state.json.has("images"):
		for image in state.json["images"]:
			uri_found = uri_found or image.has("uri")
			bufferView_found = bufferView_found or image.has("bufferView")
			
	if bufferView_found and not uri_found:
		# bufferView usage was discovered with images and no images were found that use URIs
		# try to reload, this time with embedded images on (no 0x20 flag)
		var stateWithEmbedImages = GLTFState.new()
		stateWithEmbedImages.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)
		gltf_error = document.append_from_buffer(buffer, "", stateWithEmbedImages)
		
		if gltf_error:
			push_error("An error occured parsing glTF data! Error code: %s" % gltf_error)
			# don't replace state
		else:
			state = stateWithEmbedImages # replace state with the one with embedded images
			
	return from(document, state)
	

static func from(p_document: GLTFDocument, p_state: GLTFState) -> GLTFObject:
	var obj = GLTFObject.new()
	obj.document = p_document
	obj.state = p_state
	return obj
