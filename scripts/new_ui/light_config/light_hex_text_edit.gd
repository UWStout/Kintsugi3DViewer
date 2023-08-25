# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends LineEdit

@onready var color_picker = $"../../MarginContainer/ColorPicker"

func is_hex(text : String):
	if not text.length() == 7:
		return false
	
	if not text.begins_with("#"):
		return false
	
	for char_1 in text.substr(1).to_upper():
		var is_char_valid : bool = false
		for char_2 in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "A", "B", "C", "D", "E", "F"]:
			if char_1 == char_2:
				is_char_valid = true
		
		if not is_char_valid:
			return false
	
	return true

func _on_text_changed(new_text):
	if is_hex(text):
		color_picker.change_color_from_text_edit(Color.html(text))

func _on_focus_exited():
	if not is_hex(text):
		text = "#" + color_picker.color.to_html(false)
