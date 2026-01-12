# Copyright (c) 2026 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith, Melissa Kosharek
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name ArtifactConfigButton extends MarginContainer


@export var light_strength_label : Label
@export var light_angle_label : Label
@export var miniature_color_display : Control
@export var label : Label
@export var button : Button
@export var texture_rect : TextureRect

@export var strength_scroll_bar : ScrollBar
@export var angle_scroll_bar : ScrollBar
@export var value_scroll_bar : ScrollBar

@export var expand_icon : CompressedTexture2D
@export var shrunk_icon : CompressedTexture2D


func on_button_open():
	#print("light made material")
	#connected_light.make_material()
	texture_rect.texture = expand_icon
	#connected_light.controller.select_light(null)
	pass

func on_button_close():
	#print("light made immaterial")
	#connected_light.make_immaterial()
	#connected_light.controller.force_hide_lights()
	texture_rect.texture = shrunk_icon
	pass
