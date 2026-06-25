# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

@tool
extends Sprite3D

class_name AnnotationTextbox

@export_category("Annotation")
@export_multiline var annotation_name : String = "UNNAMED ANNOTATION"
@export_multiline var annotation_text : String = "EMPTY ANNOTATION TEXT"
@export var recalculate_text : bool = false : set = recalc_text

@export var sub_viewport_container : SubViewportContainer
@export var sub_viewport : SubViewport

@export var title_text : RichTextLabel
@export var content_text : RichTextLabel

func recalc_text(new_value):
	# Update the text in the UI to match the properties of this object.
	# Because Godot wants to break itself, this is the easiest way to make changes
	# appear in the editor on-demand.
	if new_value:
		recalculate_text = false
		title_text.set_text("[b]" + annotation_name + "[b]")
		content_text.set_text("[i]" + annotation_text + "[i]")

# Called when the node enters the scene tree for the first time.
func _ready():
	#sub_viewport_container.visibility_layer |= 0
	texture = sub_viewport.get_texture()
	
	title_text.text = str("[b]", annotation_name, "[b]")
	content_text.text = str("[i]", annotation_text, "[i]")

func _enter_tree():
	if Engine.is_editor_hint():
		#sub_viewport_container.visibility_layer |= 0
		texture = sub_viewport.get_texture()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
