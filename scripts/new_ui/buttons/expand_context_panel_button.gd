# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name ExpandContextMenuButton extends ExclusiveToggleButton

@export var context_name : String
@export var context_menu : ExpandingContextPanel

func _pressed():
	if context_menu.is_animating():
		return
	
	super._pressed()

func _on_toggle_on():
	await context_menu.expand_context(context_name)

func _on_toggle_off():
	await context_menu.shrink()
