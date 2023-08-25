# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name CacheUI extends VBoxContainer

@export var artifact_display_ui : PackedScene
@export var confirmation_panel : ConfirmationPanel

func _ready():
	for artifact in CacheManager.get_artifact_data():
		var new_artifact_display = artifact_display_ui.instantiate()
		add_child(new_artifact_display)
		new_artifact_display.initialize_from_artifact(artifact)

func refresh_list():
	for child in get_children():
		child.queue_free()
	
	for artifact in CacheManager.get_artifact_data_in_cache_ordered():
		var new_artifact_display = artifact_display_ui.instantiate()
		add_child(new_artifact_display)
		new_artifact_display.initialize_from_artifact(artifact)
		new_artifact_display.confirmation_panel = confirmation_panel


func _on_cache_visibility_changed():
	refresh_list()
