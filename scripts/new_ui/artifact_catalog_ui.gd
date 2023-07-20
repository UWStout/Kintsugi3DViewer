extends VBoxContainer

@export var artifact_select_button : PackedScene
@export var artifact_controller : ArtifactsController

@onready var button_group : ExclusiveToggleGroup = $button_group
@onready var v_box_container : VBoxContainer = $ScrollContainer/VBoxContainer
@onready var searchbar : TextEdit = $header/VBoxContainer2/MarginContainer2/CenterContainer/searchbar

# Called when the node enters the scene tree for the first time.
func _ready():
	#test_func()
	if not artifact_controller == null:
		initialize_list(await artifact_controller.refresh_artifacts())

func initialize_list(data : Array[ArtifactData]):
	for artifact in data:
		create_button(artifact)

func test_func():
	for i in range(1, 4):
		var button = artifact_select_button.instantiate() as ArtifactSelectionButton
		v_box_container.add_child(button)
		#button.set_button_name("button " + str(i))
		button_group.register_button(button)
		button.toggle_group = button_group
		
		pass
	pass

func create_button(data : ArtifactData):
	var button = artifact_select_button.instantiate() as ArtifactSelectionButton
	v_box_container.add_child(button)
	
	button.set_data(data, artifact_controller)
	
	button_group.register_button(button)
	button.toggle_group = button_group

func hide_non_matching(name : String):
	for child in v_box_container.get_children():
		var button = child as ArtifactSelectionButton
		if button.data.name.begins_with(name):
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
