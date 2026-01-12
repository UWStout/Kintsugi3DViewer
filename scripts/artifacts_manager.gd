# Copyright (c) 2026 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith, Melissa Kosharek
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name ArtifactsManager extends Node3D

var active_controller : ArtifactsController
signal active_controller_changed(new_controller: ArtifactsController)

@export var local : LocalArtifactsController
@export var server : ServerArtifactsController

func _ready() -> void:
	set_active_controller(local)

func set_active_controller(controller: ArtifactsController):
	if active_controller == controller:
		return
	active_controller = controller
	emit_signal("active_controller_changed", active_controller)

func toggle_to_local():
	set_active_controller(local)

func toggle_to_server():
	set_active_controller(server)
