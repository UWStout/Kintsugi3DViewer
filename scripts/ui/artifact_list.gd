extends Panel

@export var artifact_button: PackedScene

@onready var artifact_catalog = ArtifactCatalog

func _ready():
	hide_panel()
	if not is_instance_valid(artifact_button):
		push_error("Artifact button not set!")
	artifact_catalog.artifacts_loaded.connect(
		func(_artifacts):
			populate_list())

func show_panel():
	show()
	#populate_list()

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
	for artifact_data in artifact_catalog.get_artifacts():
		var button = artifact_button.instantiate()
		%ArtifactList.add_child(button)
		button.setup(artifact_data)
