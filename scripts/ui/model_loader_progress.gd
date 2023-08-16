# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Control
class_name ModelLoaderProgress

#@onready var progressBar: ProgressBar = $Panel/MarginContainer/VBoxContainer/ProgressBar
@export var progressBar : ProgressBar
@export var text_label : Label

func _ready():
	end_loading()


func update_progress(progress: float):
	if not progressBar == null:
		progressBar.value = progress
	
	if not text_label == null:
		text_label.text = "LOADING (" + str((progress * 100) as int) + "%)"


func start_loading():
	show()
	update_progress(0)


func end_loading():
	hide()
