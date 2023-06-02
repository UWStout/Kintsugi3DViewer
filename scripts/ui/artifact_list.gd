extends Panel

@export var artifact_button: PackedScene

func _ready():
	hide_panel()
	if not is_instance_valid(artifact_button):
		push_error("Artifact button not set!")

func show_panel():
	populate_list()
	show()

func hide_panel():
	hide()

func toggle_panel():
	if is_visible_in_tree():
		hide_panel()
	else:
		show_panel()

func clear_list():
	for child in %ArtifactList.get_children():
		child.queue_free()

func populate_list():
	clear_list()
	var button = artifact_button.instantiate()
	button.text = "runtime button text!"
	%ArtifactList.add_child(button)
