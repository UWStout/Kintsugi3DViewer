# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends ExclusiveToggleButton

@export var parent_panel : ExpandingPanel
@export var parent_config_button : LightConfigButton

func _on_toggle_on():
	parent_panel.expand()
	parent_config_button.on_button_open()
	
	super._on_toggle_on()

func _on_toggle_off():
	parent_panel.shrink()
	parent_config_button.on_button_close()
	
	super._on_toggle_off()
