# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name ContextMenu extends Control

@export var connected_button : ExclusiveToggleButton

func on_context_expanded():
	if not connected_button == null and not connected_button._is_toggled:
		connected_button.toggle_on()


func on_context_shrunk():
	if not connected_button == null and connected_button._is_toggled:
		connected_button.toggle_off()
