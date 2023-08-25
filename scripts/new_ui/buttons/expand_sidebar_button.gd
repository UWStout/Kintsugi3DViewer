# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name ExpandSiderbarButton extends ExclusiveToggleButton

@onready var texture_rect = $CenterContainer/TextureRect

var toggled_on_icon = preload("res://assets/UI 2D/Icons/SideFlyout/V2/SideFlyout_In_White_V2.svg")
var toggled_off_icon = preload("res://assets/UI 2D/Icons/SideFlyout/V2/SideFlyout_Out_White_V2.svg")


@export var sidebar_selection_menu : SidebarSelectionMenu

func _pressed():
	if sidebar_selection_menu._expanding or sidebar_selection_menu._shrinking:
		return
	
	super._pressed()

func _on_toggle_on():
	sidebar_selection_menu.expand_sidebar()
	
	super._on_toggle_on()

func _on_toggle_off():
	sidebar_selection_menu.shrink_sidebar()
	
	super._on_toggle_off()

func _display_toggled_on():
	texture_rect.texture = toggled_on_icon
	super._display_toggled_on()

func _display_toggled_off():
	texture_rect.texture = toggled_off_icon
	super._display_toggled_off()
