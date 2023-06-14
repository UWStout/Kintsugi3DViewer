extends Node3D

class_name LightingController

@export var connected_button : SelectLightingButton
@export var connected_moving_light_controller : MovableLightingController

var presets : Array[LightingPreset]
var active_index : int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	# Each child of the controller that is a LightingPreset is included in the list
	for child in get_children():
		if child is LightingPreset:
			register_new_preset(child)
			child.visible = false
			
	connected_button.connected_controller = self
	connected_button.init()

func make_active(preset_index : int):
	# If this newly selected preset isn't valid, do nothing
	if preset_index < 0 or preset_index > presets.size():
		return
	
	# if there is a currently selected preset, disable it
	if(active_index >= 0):
		presets[active_index].visible = false
	
	# enable the newly selected preset
	active_index = preset_index
	presets[active_index].visible = true
	
	connected_moving_light_controller.provide_preset(presets[active_index])

# register a new preset to this controllers list, only if
# it doesn't already exist in the list, and update the button
func register_new_preset(new_preset : LightingPreset):
	if presets.find(new_preset) < 0:
		presets.append_array([new_preset])
		connected_button.add_item(new_preset.preset_name, presets.find(new_preset))

# remove a preset from the list and update the button
func remove_preset(preset_index : int):
	if preset_index >= 0 and preset_index < presets.size():
		presets.remove_at(preset_index)
		connected_button.remove_item(preset_index)
