@tool
extends EditorPlugin

var plugin
var csvPlugin

func _enter_tree():
	# Initialization of the plugin goes here.
	plugin = preload("res://addons/load_texture_array/texture_array_inspector.gd").new()
	csvPlugin = preload("res://addons/load_texture_array/import_1d_texture_array_from_csv.gd").new()
	add_inspector_plugin(plugin)
	add_import_plugin(csvPlugin, true)

func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_inspector_plugin(plugin)
	remove_import_plugin(csvPlugin)
