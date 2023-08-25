# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

extends MarginContainer

@onready var name_label = $Panel/HBoxContainer/CenterContainer/HBoxContainer/name_label
@onready var size_label = $Panel/HBoxContainer/CenterContainer/HBoxContainer/size_label

@onready var delete_button = $Panel/HBoxContainer/CenterContainer2/delete_button
@onready var favorite_button = $Panel/HBoxContainer/CenterContainer3/favorite_button

var artifact_name : String
var artifact_url_name : String

var confirmation_panel : ConfirmationPanel

func initialize_from_artifact(data : ArtifactData):
	artifact_name = data.name
	artifact_url_name = data.gltfUri.get_base_dir()
	
	name_label.text = artifact_name
	size_label.text = "(" + str(CacheManager.get_size_in_mb(artifact_url_name)) + " mb)"
	
	if CacheManager.is_persistent(artifact_url_name):
		favorite_button.toggle_on()
	
	CacheManager.cache_item_deleted.connect(check_if_valid)

func _on_delete_button_pressed():
	confirmation_panel.prompt_confirmation("REMOVE FROM CACHE", "You will need to download it if you want to view it again.", canceled, delete_artifact) 
	#self.queue_free()

func check_if_valid():
	if not CacheManager.is_in_cache(artifact_url_name):
		self.queue_free()
	pass

func delete_artifact():
	CacheManager.remove_from_cache(artifact_url_name)

func canceled():
	pass
