class_name ExpandingContextPanel extends ExpandingPanel

@export var contexts : Array[NodePath] = []

var _contexts_dict = { "context_name" : "context_object" }
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
	
	if _contexts_dict.has(_selected_context):
		_contexts_dict[_selected_context].visible = true
	await super.expand()

func shrink():
	if not is_expanded or _shrinking:
		return
	
	await super.shrink()
	if _contexts_dict.has(_selected_context):
		_contexts_dict[_selected_context].visible = false

