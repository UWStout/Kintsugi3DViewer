# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends ExtendedButton

enum mode_enum {NEXT, PREVIOUS}

@export var mode : mode_enum = 0

@export var artifact_controller : ArtifactsController

func _pressed():
	if mode == mode_enum.NEXT:
		artifact_controller.display_next_artifact()
	else:
		artifact_controller.display_previous_artifact()
