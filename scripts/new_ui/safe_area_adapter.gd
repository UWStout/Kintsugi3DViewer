# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends MarginContainer

func _ready():
	#if not OS.get_name() == "Android" and not OS.get_name() == "iOS":
		#return
	
	var safe_area = DisplayServer.get_display_safe_area()
	
	var screen_width = DisplayServer.screen_get_size().x
	var screen_height = DisplayServer.screen_get_size().y
	
	var scale_factor = DisplayServer.window_get_size().x / (screen_width as float)
	
	
	add_theme_constant_override("margin_top", safe_area.position.y * scale_factor)
	add_theme_constant_override("margin_left", safe_area.position.x * scale_factor)
	add_theme_constant_override("margin_bottom", DisplayServer.window_get_size().y - safe_area.size.y * scale_factor)
	add_theme_constant_override("margin_right", DisplayServer.window_get_size().x - safe_area.size.x * scale_factor)
