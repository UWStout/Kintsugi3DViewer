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
		artifacts_controller._open_artifact_through_file(result)
		self.clear()
		self.placeholder_text = "Enter index here"
		popup.visible = false
		popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
