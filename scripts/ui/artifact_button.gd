# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends Button

var data: ArtifactData

func _pressed():
	print("Artifact button '%s' pressed!" % data.name)
	#TODO: Load the object using urls found in the data dictionary

func setup(artifact_data: ArtifactData):
	data = artifact_data
	text = data.name
	var placeholder = icon.get_image()
	icon = HTTPImageTexture.new()
	icon.set_image(placeholder)
	icon.set_url(data.iconUri)
	icon.load(self)
