# Copyright (c) 2026 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith, Melissa Kosharek
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
extends LineEdit

@export var artifacts_controller : ArtifactsController
@export var popup : Control

func _on_text_submitted(new_text: String) -> void:
	var index := int(new_text)
	var data = LocalSaveData.get_dict()
	if(index >= data["artifacts"].size() or index<0 or index == null):
		self.clear()
		self.placeholder_text = "Requested index is out of range."
	elif(index < data["artifacts"].size() or index>=0):
		var result = data["artifacts"][index]["localDir"]
		artifacts_controller._open_saved_artifact_through_file(result)
		self.clear()
		self.placeholder_text = "Enter index here"
		popup.visible = false
		popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
