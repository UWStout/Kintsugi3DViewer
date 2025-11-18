# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name ExtendedButton extends Button

func set_normal_style(style : StyleBox):
	if not style == null:
		remove_theme_stylebox_override("normal")
		add_theme_stylebox_override("normal", style)

func set_hover_style(style : StyleBox):
	if not style == null:
		remove_theme_stylebox_override("hover")
		add_theme_stylebox_override("hover", style)

func set_pressed_style(style : StyleBox):
	if not style == null:
		remove_theme_stylebox_override("pressed")
		add_theme_stylebox_override("pressed", style)

func set_disabled_style(style : StyleBox):
	if not style == null:
		remove_theme_stylebox_override("disabled")
		add_theme_stylebox_override("disabled", style)

func set_focus_style(style : StyleBox):
	if not style == null:
		remove_theme_stylebox_override("focus")
		add_theme_stylebox_override("focus", style)

func set_font_normal_color(color: Color):
	if not color == null:
		remove_theme_color_override("font_color")
		add_theme_color_override("font_color", color)

func set_font_hover_color(color: Color):
	if not color == null:
		remove_theme_color_override("font_hover_color")
		add_theme_color_override("font_hover_color", color)
		
func set_font_pressed_color(color: Color):
	if not color == null:
		remove_theme_color_override("font_pressed_color")
		add_theme_color_override("font_pressed_color", color)
		
func set_font_disabled_color(color: Color):
	if not color == null:
		remove_theme_color_override("font_disabled_color")
		add_theme_color_override("font_disabled_color", color)
