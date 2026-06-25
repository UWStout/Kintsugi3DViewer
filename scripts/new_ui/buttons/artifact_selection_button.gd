# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name ArtifactSelectionButton extends ExclusiveToggleButton

@export var artifact_label : Label
@export var artifact_preview : TextureRect
@export var artifact_status : TextureRect
@export var favorite_artifact_button : Button

@export var not_downloaded_icon : CompressedTexture2D
@export var downloaded_icon : CompressedTexture2D
@export var favorited_icon : CompressedTexture2D

var data : ArtifactData
var controller : ArtifactsController

var local_favorite : bool = false
	
	
func set_data(new_data : ArtifactData, new_controller : ArtifactsController):
	data = new_data
	controller = new_controller
	artifact_label.text = data.name

func _pressed():
	if not controller == null and not controller.loaded_artifact == null:
		if not controller.loaded_artifact.load_finished:
			return
	
	super._pressed()

func _on_toggle_on():
	if not controller == null:
		controller.open_artifact(data)
		for button in toggle_group.connected_buttons:
			if not button == self:
				button.make_inactive()
	
	super._on_toggle_on()

func _on_toggle_off():
	super._on_toggle_off()

func _display_toggled_on():
	artifact_label.self_modulate = Color8(36, 36, 36, 255)
	artifact_preview.self_modulate = Color8(36, 36, 36, 255)
	artifact_status.self_modulate = Color8(36, 36, 36, 255)
	super._display_toggled_on()

func _display_toggled_off():
	artifact_label.self_modulate = Color8(217, 217, 217, 255)
	artifact_preview.self_modulate = Color8(217, 217, 217, 255)
	artifact_status.self_modulate = Color8(217, 217, 217, 255)
	super._display_toggled_off()

func make_inactive():
	if controller.loaded_artifact.load_finished:
		return
	
	artifact_label.self_modulate = Color8(167, 167, 167, 255)
	artifact_preview.self_modulate = Color8(167, 167, 167, 255)

func _on_favorite_artifact_button_pressed():
	if controller is LocalArtifactsController:
		local_favorite = not local_favorite
		return
	if not CacheManager.is_in_cache(data.gltfUri.get_base_dir()):
		return
	
	if CacheManager.is_persistent(data.gltfUri.get_base_dir()):
		CacheManager.make_not_persistent(data.gltfUri.get_base_dir())
	else:
		CacheManager.make_persistent(data.gltfUri.get_base_dir())

func _process(delta):
	#print(data.localDir)

	if controller is LocalArtifactsController:
		favorite_artifact_button.show()
		if not local_favorite:
			artifact_status.texture = favorited_icon
		else:
			artifact_status.texture = downloaded_icon
	else:
		if CacheManager.is_in_cache(data.gltfUri.get_base_dir()):
			favorite_artifact_button.show()
			artifact_status.texture = downloaded_icon
			
			if CacheManager.is_persistent(data.gltfUri.get_base_dir()):
				artifact_status.texture = favorited_icon
		else:
			artifact_status.texture = not_downloaded_icon
			favorite_artifact_button.hide()
	
	pass
