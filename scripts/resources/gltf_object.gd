extends RefCounted
class_name GLTFObject

var document: GLTFDocument
var state: GLTFState
var sourceUri: String


func generate_scene() -> Node:
	return document.generate_scene(state)
