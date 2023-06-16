extends RefCounted
class_name GLTFObject

var document: GLTFDocument
var state: GLTFState
var sourceUri: String


func generate_scene() -> Node:
	if document == null or state == null:
		return null
	return document.generate_scene(state)
