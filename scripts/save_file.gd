# Copyright (c) 2026 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith, Melissa Kosharek
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
extends Button

@export var fileName: LineEdit
@export var popup: CenterContainer

signal file_name_chosen(name: String)

func _on_pressed() -> void:
	var name = fileName.text.strip_edges()
	fileName.clear
	fileName.placeholder_text = "Please name the current model to save"

	emit_signal("file_name_chosen", name)


func _get_file_name(file: String) -> void:
	await self.pressed
	if not fileName.get_text() == "":
		name = fileName.get_text()
	else:
		name = (file.get_slice("/", (file.get_slice_count("/")-2)))
	popup.visible = false
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
