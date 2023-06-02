extends Panel

@export var artifact_button: PackedScene

var test_data = [
	{
		"name": "Test Object A",
		"iconUrl": "https://i.imgur.com/j9tpg3M.jpg"
	},
	{
		"name": "Test Object B",
		"iconUrl": "https://i.imgur.com/j9tpg3M.jpg"
	},
	{
		"name": "Test Object C",
		"iconUrl": "https://i.imgur.com/j9tpg3M.jpg"
	}
]

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
	for artifact_data in test_data:
		var button = artifact_button.instantiate()
		%ArtifactList.add_child(button)
		button.setup(artifact_data)
