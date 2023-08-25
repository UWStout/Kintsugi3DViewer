# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Control

@export var hide_ui_button : HideUIButton
@export var top_dock : ExpandingPanel
@export var settings_menu : Control

var was_mouse_inside : bool = false
var was_mouse_outside : bool = false


func _ready():
	top_dock.is_expanded = true

func _input(event):
	match OS.get_name():
		"Windows", "UWP", "macOS", "Linux", "FreeBSD", "NetBSD", "openBSD", "BSD", "Web":
			pass
		_:
			return
	
	if event is InputEventMouseMotion:
		var pos = event.position as Vector2
		
		if pos.y <= 85:
			if not top_dock.is_expanded and hide_ui_button._is_toggled and not settings_menu.visible:
				top_dock.expand()
		else:
			if top_dock.is_expanded and hide_ui_button._is_toggled and not settings_menu.visible:
				top_dock.shrink()

