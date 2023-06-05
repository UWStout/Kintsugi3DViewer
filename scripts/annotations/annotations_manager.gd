extends Node

var annotation_markers_array = []
var selected_annotation_index : int = -1

func register_new_annotation(annotation_marker):
	annotation_markers_array.append_array([annotation_marker])
	
func change_selected_annotation(new_selection):
	# If the new selected annotation is the same as the current one, do nothing
	if selected_annotation_index == annotation_markers_array.find(new_selection):
		return
	
	# If there is a currently selected annotation, unselect it
	if not selected_annotation_index == -1:
		annotation_markers_array[selected_annotation_index].unselect_annotation()
	
	# Find the index of the newly selected annotation
	selected_annotation_index = annotation_markers_array.find(new_selection)
	
	# If the newly selected annotation is in the list, select it
	if not selected_annotation_index == -1:
		annotation_markers_array[selected_annotation_index].select_annotation()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	selected_annotation_index = -1
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
