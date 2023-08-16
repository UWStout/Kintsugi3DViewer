# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends ExtendedButton

@export var confirmation_panel : ConfirmationPanel

func _pressed():
	if not CacheManager.is_empty():
		confirmation_panel.prompt_confirmation("CLEAR LOCAL DATA", "This will remove ALL objects from the cache, including favorites. This cannot be undone.", canceled, clear_cache)

func clear_cache():
	CacheManager.clear_cache()

func canceled():
	pass
