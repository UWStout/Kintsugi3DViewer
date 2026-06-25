# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends LineEdit

@export var owner_node : Node

func _ready():
	if not Preferences.read_pref("allow ip change"):
		owner_node.visible = false
	else:
		var read_text = Preferences.read_pref("ip")
		if not read_text == null:
			text = read_text

func _on_text_changed(new_text):
	Preferences.write_pref("ip", new_text)
