# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name ExclusiveToggleButton extends ToggleButton

@export var toggle_group : ExclusiveToggleGroup

func _ready():
	if not toggle_group == null:
		toggle_group.register_button(self)

	if _start_toggled and not _is_toggled:
		toggle_group.make_button_active(self)
	
	super._ready()

func _pressed():
	if toggle_group == null:
		return
	
	if not _is_toggled:
		toggle_group.make_button_active(self)
	else:
		toggle_group.make_button_inactive(self)

func _on_toggle_on():
	if not toggle_group == null:
		if not toggle_group.can_toggle_off_all:
			disabled = true
	
	await super._on_toggle_on()

func _on_toggle_off():
	disabled = false
	await super._on_toggle_off()
