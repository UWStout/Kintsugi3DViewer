extends Node3D

class_name LightingController

var presets : Array[LightingPreset]
var active_index : int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is LightingPreset:
			register_new_preset(child)
			child.visible = false
	make_active(0)

func make_active(preset_index : int):
	if preset_index < 0 or preset_index >= presets.size():
		return
	
	if(active_index > 0):
		presets[active_index].visible = false
	
	active_index = preset_index
	presets[active_index].visible = true

func register_new_preset(new_preset : LightingPreset):
	if presets.find(new_preset) < 0:
		presets.append_array([new_preset])
		
		# do code to update the button's list

func remove_preset(preset_index : int):
	if preset_index >= 0 and preset_index < presets.size():
		presets.remove_at(preset_index)
		
		# do code to remove preset from button
