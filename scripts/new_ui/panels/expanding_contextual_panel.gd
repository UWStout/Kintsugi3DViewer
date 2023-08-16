# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name ExpandingContextPanel extends ExpandingPanel

@export var contexts : Array[NodePath] = []

var _contexts_dict = {}
var _selected_context : String = "NULL"

func _ready():
	for context in contexts:
		var context_object = get_node(context) as Control
		_contexts_dict[context.get_name(0)] = context_object
		
		#await expand_context("artifact_catalog")
		#shrink_out_context()

func expand_context(new_context : String):
	if not _contexts_dict.has(new_context):
		return
	
	_selected_context = new_context
	expand()

func expand():
	if is_expanded or _expanding:
		return

	hide_all_contexts()
	
	if _contexts_dict.has(_selected_context):
		_contexts_dict[_selected_context].visible = true
		if _contexts_dict[_selected_context] is ContextMenu:
			_contexts_dict[_selected_context].on_context_expanded()
	await super.expand()

func shrink():
	if not is_expanded or _shrinking:
		return
	
	await super.shrink()
	if _contexts_dict.has(_selected_context):
		_contexts_dict[_selected_context].visible = false
		if _contexts_dict[_selected_context] is ContextMenu:
			_contexts_dict[_selected_context].on_context_shrunk()

func is_context_expanded(context_name : String) -> bool:
	if _contexts_dict.has(_selected_context):
		return _contexts_dict[_selected_context].name == context_name
	return false

func hide_all_contexts():
	for context in _contexts_dict:
		if not _contexts_dict[context] == null:
			_contexts_dict[context].visible = false
	pass
