@tool
extends EditorPlugin

var plugin

func _enter_tree():
	# Initialization of the plugin goes here.
	plugin = preload("res://addons/load_texture_array/texture_array_inspector.gd").new()
	add_inspector_plugin(plugin)

func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_inspector_plugin(plugin)
