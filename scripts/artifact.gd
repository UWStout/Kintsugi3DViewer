# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Node3D

@export var artifact_name : String = "Unnamed Artifact"
@export var artifact_description : String = "No Description Available"

@export var artifact_model : Node3D
@export var annotations : Array[NodePath]

func select_artifact():
	for annotation_node_path in annotations:
		var annotation_marker = get_node(annotation_node_path)
		AnnotationsManager.register_new_annotation(annotation_marker)
		annotation_marker.collision_layer = 2
	pass

func deselect_artifact():
	AnnotationsManager.change_selected_annotation(null)
	AnnotationsManager.clear_annotations_array()
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
