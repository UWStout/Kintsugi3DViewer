# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends ToggleButton

func _ready():
	if Preferences.read_pref("offline mode"):
		text = "ON"
		_is_toggled = true
	else:
		text = "OFF"

func _on_toggle_on():
	Preferences.write_pref("offline mode", true)
	text = "ON"
	
	super._on_toggle_on()

func _on_toggle_off():
	Preferences.write_pref("offline mode", false)
	text = "OFF"
	
	super._on_toggle_off()
