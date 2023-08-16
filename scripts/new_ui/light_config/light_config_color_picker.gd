# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends ColorPicker

@onready var light_config_button = $"../../../../.."
@onready var text_edit = $"../../MarginContainer2/TextEdit"


func _on_color_changed(color):
	light_config_button.update_light_color(color)
	text_edit.text = "#" + color.to_html()

func change_color_from_text_edit(new_color : Color):
	color = new_color
	light_config_button.update_light_color(color)
