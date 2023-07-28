extends ExtendedButton

enum mode_enum {NEXT, PREVIOUS}

@export var mode : mode_enum = 0

@export var artifact_controller : ArtifactsController

func _pressed():
	if mode == mode_enum.NEXT:
		artifact_controller.display_next_artifact()
	else:
		artifact_controller.display_previous_artifact()
