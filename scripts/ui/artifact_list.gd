# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Panel

@export var artifact_button: PackedScene

@onready var artifact_catalog = ArtifactCatalog

func _ready():
	hide_panel()
	if not is_instance_valid(artifact_button):
		push_error("Artifact button not set!")
	artifact_catalog.artifacts_loaded.connect(
		func(_artifacts):
			populate_list())

func show_panel():
	show()
	#populate_list()

func hide_panel():
	hide()

func toggle_panel():
	if is_visible_in_tree():
		hide_panel()
	else:
		show_panel()

func clear_list():
	for child in %ArtifactList.get_children():
		child.queue_free()

func populate_list():
	clear_list()
	for artifact_data in artifact_catalog.get_artifacts():
		var button = artifact_button.instantiate()
		%ArtifactList.add_child(button)
		button.setup(artifact_data)
