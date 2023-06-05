extends Panel

@export var artifact_button: PackedScene
@export var remote_data_url: String

var artifacts_data: Array

func _ready():
	hide_panel()
	if not is_instance_valid(artifact_button):
		push_error("Artifact button not set!")

func show_panel():
	show()
	load_remote_data()

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
	for artifact_data in artifacts_data:
		var button = artifact_button.instantiate()
		%ArtifactList.add_child(button)
		button.setup(artifact_data)

func load_remote_data():
	var req = HTTPRequest.new()
	add_child(req)
	req.request_completed.connect(_on_request_completed)
	req.request(remote_data_url)

func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		push_error("Failed to retrieve remote URL!")
	
	var parsed_data = JSON.parse_string(body.get_string_from_utf8())
	artifacts_data = parsed_data
	populate_list()
