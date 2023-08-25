# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Button

class_name SelectArtifactButton

var target_artifact: ArtifactData
@export var parent_window : Window

@onready var artifacts_controller : ArtifactsController = $"../../../../artifacts_controller"

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_instance_valid(target_artifact):
		return
	text = target_artifact.name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _pressed():
	if not artifacts_controller == null:
		artifacts_controller.display_artifact_data(target_artifact)
		parent_window.close_requested.emit()
	
	pass
