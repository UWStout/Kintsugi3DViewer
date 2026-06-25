# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends ToggleButton

@export var cache_artifact_display : Control
@export var texture_rect : TextureRect

@export var favorited_icon : CompressedTexture2D
@export var not_favorited_icon : CompressedTexture2D

func _on_toggle_on():
	CacheManager.make_persistent(cache_artifact_display.artifact_url_name)
	display_favorited()
	super._on_toggle_on()

func _on_toggle_off():
	CacheManager.make_not_persistent(cache_artifact_display.artifact_url_name)
	display_not_favorited()
	super._on_toggle_off()

func display_favorited():
	texture_rect.texture = favorited_icon

func display_not_favorited():
	texture_rect.texture = not_favorited_icon
