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
