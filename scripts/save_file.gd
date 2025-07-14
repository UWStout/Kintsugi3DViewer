extends Button

@export var fileName: LineEdit
@export var popup: CenterContainer

signal file_name_chosen(name: String)

func _on_pressed() -> void:
	var name = fileName.text.strip_edges()
	emit_signal("file_name_chosen", name)
	#fileName.get_text()
	#pull current filepath
	#how to? -> global variable? would have to mess around with local vs cloud, probably more work than its worth
	#		pass the variable directly to this script: open popup -> 


func _get_file_name(file: String) -> void:
	await self.pressed
	if not fileName.get_text() == "":
		name = fileName.get_text()
	else:
		name = (file.get_slice("/", (file.get_slice_count("/")-2)))
	popup.visible = false
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
