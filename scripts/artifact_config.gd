class_name ArtifactConfigurationUI extends ContextMenu

@export var environment_selection_button : PackedScene
@export var environment_controller : EnvironmentController

@export var button_group : ExclusiveToggleGroup
@export var v_box_container : BoxContainer
@export var searchbar : TextEdit

func initialize_list(environments : Array[DisplayEnvironment]):
	for i in range(0, environments.size()):
		create_button(i, environments[i].environment_name)
	
	if v_box_container.get_child_count() >= 1:
		v_box_container.get_child(0)._pressed()

func create_button(index : int, button_name : String):
	var button = environment_selection_button.instantiate() as EnvironmentSelectionButton
	v_box_container.add_child(button)
	
	button.set_data(index, button_name, environment_controller)
	
	button_group.register_button(button)

func hide_non_matching(name : String):
	for child in v_box_container.get_children():
		var button = child as EnvironmentSelectionButton
		if button.environment_name.to_lower().begins_with(name.to_lower()):
			button.visible = true
		else:
			button.visible = false

func show_all():
	for child in v_box_container.get_children():
		var button = child
		button.visible = true

func _on_searchbar_text_changed():
	var text = searchbar.text
	
	if text.is_empty():
		show_all()
	else:
		hide_non_matching(text)
