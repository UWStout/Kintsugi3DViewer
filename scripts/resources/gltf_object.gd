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


static func from(p_document: GLTFDocument, p_state: GLTFState) -> GLTFObject:
	var obj = GLTFObject.new()
	obj.document = p_document
	obj.state = p_state
	return obj
