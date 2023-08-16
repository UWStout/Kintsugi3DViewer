# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends StaticBody3D

class_name AnnotationMarker

@export var focus_point : AnnotationFocusPoint
@export var textbox: AnnotationTextbox

func get_focus_point():
	if not focus_point == null:
		return focus_point
	else:
		printerr(str(name, " has no focus_point!"))
		return null

func get_textbox():
	if not textbox == null:
		return textbox
	else:
		printerr(str(name, " has no textbox!"))
		return null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Register this annotation marker to the Annotations Manager
	# to make sure it is controlled properly
	#AnnotationsManager.register_new_annotation(self)
	
	collision_layer = 0
	
	if not textbox == null:
		textbox.visible = false
	pass

func select_annotation():
	print(name + " was selected!")
	
	# When an annotation is selected, it's marker becomes invisible
	# and it's textbox appears
	visible = false
	textbox.visible = true

func unselect_annotation():
	print(name + " was unselected!")
	
	# When an annotation is unselected, it's marker becomes visible again and
	# it's textbox dissappears
	visible = true
	textbox.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

func on_annotation_clicked():
	AnnotationsManager.change_selected_annotation(self)
