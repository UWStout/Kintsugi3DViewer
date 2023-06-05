@tool
extends Sprite3D

class_name AnnotationTextbox

@export_category("Annotation")
@export var annotation_name : String = "UNNAMED ANNOTATION"
@export var annotation_text : String = "EMPTY ANNOTATION TEXT"
@export var recalculate_text : bool = false : set = recalc_text

@onready var sub_viewport_container = $SubViewportContainer
@onready var sub_viewport = $SubViewportContainer/SubViewport

@onready var title_text = $SubViewportContainer/SubViewport/PanelContainer/VBoxContainer/TitleText 
@onready var content_text = $SubViewportContainer/SubViewport/PanelContainer/VBoxContainer/ContentText 

func recalc_text(new_value):
	# Update the text in the UI to match the properties of this object.
	# Because Godot wants to break itself, this is the easiest way to make changes
	# appear in the editor on-demand.
	if new_value:
		recalculate_text = false
		title_text.text = str("[b]", annotation_name, "[b]")
		content_text.text = str("[i]", annotation_text, "[i]")

# Called when the node enters the scene tree for the first time.
func _ready():
	#sub_viewport_container.visibility_layer |= 0
	texture = sub_viewport.get_texture()
	
	title_text.text = str("[b]", annotation_name, "[b]")
	content_text.text = str("[i]", annotation_text, "[i]")

func _enter_tree():
	if Engine.is_editor_hint():
		#sub_viewport_container.visibility_layer |= 0
		texture = sub_viewport.get_texture()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
