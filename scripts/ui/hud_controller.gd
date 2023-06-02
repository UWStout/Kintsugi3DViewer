extends CanvasLayer

func _ready():
	%ArtifactListPanel.hide()

func _on_button_change_artifact_pressed():
	%ArtifactListPanel.show()
