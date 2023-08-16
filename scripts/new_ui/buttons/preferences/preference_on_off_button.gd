# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends OnOffButton

@export var preference_name : String

func _ready():
	var pref = Preferences.read_pref(preference_name)
	if not pref == null and pref is bool:
		_start_toggled = Preferences.read_pref(preference_name)
	
	super._ready()

func _on_toggle_on():
	Preferences.write_pref(preference_name, true)
	super._on_toggle_on()

func _on_toggle_off():
	Preferences.write_pref(preference_name, false)
	super._on_toggle_off()
