extends Button

@export var fileName: LineEdit
@export var popup: CenterContainer

signal file_name_chosen(name: String)

func _on_pressed() -> void:
	var name = fileName.text.strip_edges()
	fileName.clear
	fileName.placeholder_text = "Please name the current model to save"

	emit_signal("file_name_chosen", name)


func _get_file_name(file: String) -> void:
	await self.pressed
	if not fileName.get_text() == "":
		name = fileName.get_text()
	else:
		name = (file.get_slice("/", (file.get_slice_count("/")-2)))
	popup.visible = false
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
