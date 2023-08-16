# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name ArtifactCatalogUI extends ContextMenu

@export var artifact_select_button : PackedScene
@export var artifact_controller : ArtifactsController

@onready var button_group : ExclusiveToggleGroup = $button_group
@onready var v_box_container : VBoxContainer = $ScrollContainer/VBoxContainer
@onready var searchbar : LineEdit = $header/VBoxContainer2/MarginContainer2/CenterContainer/searchbar

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

func _on_searchbar_text_changed(new_text : String):
	var text = new_text
	
	if text.is_empty():
		show_all()
	else:
		hide_non_matching(text)

func clear_buttons():
	
	for child in v_box_container.get_children():
		if button_group.connected_buttons.has(child):
			button_group.connected_buttons.remove_at(button_group.connected_buttons.find(child))
		v_box_container.remove_child(child)
		child.free()

func on_context_expanded():
	refresh_list()
	super.on_context_expanded()

func refresh_list():
	await clear_buttons()
	
	if not artifact_controller == null:
		await initialize_list(await artifact_controller.refresh_artifacts())
	
	if not artifact_controller.loaded_artifact == null:
		var button = get_button_for_artifact(artifact_controller.loaded_artifact.artifact)
		if not button == null:
			button.toggle_group.make_button_active(button)

func get_button_for_artifact(data : ArtifactData) -> ArtifactSelectionButton:
	for button in v_box_container.get_children():
		var artifact_button = button as ArtifactSelectionButton
		if artifact_button.data.name == data.name:
			return artifact_button
	
	return null

func get_buttons():
	return v_box_container.get_children()
