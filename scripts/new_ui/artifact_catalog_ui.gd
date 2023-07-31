extends ContextMenu

@export var artifact_select_button : PackedScene
@export var artifact_controller : ArtifactsController

@onready var button_group : ExclusiveToggleGroup = $button_group
@onready var v_box_container : VBoxContainer = $ScrollContainer/VBoxContainer
@onready var searchbar : TextEdit = $header/VBoxContainer2/MarginContainer2/CenterContainer/searchbar

func _ready():
	refresh_list()

func initialize_list(data : Array[ArtifactData]):
	for artifact in data:
		create_button(artifact)
	
	#if v_box_container.get_child_count() >= 1:
		#v_box_container.get_child(0)._pressed()

func create_button(data : ArtifactData):
	var button = artifact_select_button.instantiate() as ArtifactSelectionButton
	v_box_container.add_child(button)
	
	button.set_data(data, artifact_controller)
	
	button_group.register_button(button)

func hide_non_matching(name : String):
	for child in v_box_container.get_children():
		var button = child as ArtifactSelectionButton
		
		if button.data.name.to_lower().begins_with(name.to_lower()):
			button.visible = true
		else:
			button.visible = false

func show_all():
	for child in v_box_container.get_children():
		var button = child as ArtifactSelectionButton
		button.visible = true

func _on_searchbar_text_changed():
	var text = searchbar.text
	
	if text.is_empty():
		show_all()
	else:
		hide_non_matching(text)

func clear_buttons():
	for child in v_box_container.get_children():
		child.queue_free()

func on_context_expanded():
	refresh_list()

func refresh_list():
	clear_buttons()
	
	if not artifact_controller == null:
		initialize_list(await artifact_controller.refresh_artifacts())
