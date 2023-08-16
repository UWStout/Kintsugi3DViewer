# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Node

var annotation_markers_array = []
var selected_annotation_index : int = -1

var is_material : bool = true

func register_new_annotation(annotation_marker : AnnotationMarker):
	annotation_markers_array.append_array([annotation_marker])
	
	if is_material:
		annotation_marker.collision_layer = 2
		annotation_marker.visible = true
	else:
		annotation_marker.collision_layer = 0
		annotation_marker.visible = false
	
func change_selected_annotation(new_selection : AnnotationMarker):
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
	
func clear_annotations_array():
	for annotation in annotation_markers_array:
		annotation.collision_layer = 0
	annotation_markers_array = []
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	selected_annotation_index = -1
	pass # Replace with function body.

func make_immaterial():
	is_material = false
	change_selected_annotation(null)
	
	for annotation in annotation_markers_array:
		annotation.collision_layer = 0
		annotation.visible = false

func make_material():
	is_material = true
	for annotation in annotation_markers_array:
		annotation.collision_layer = 2
		annotation.visible = true
	pass
