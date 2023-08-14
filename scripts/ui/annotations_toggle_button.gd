extends Button

@onready var annotations_on_icon = preload("res://assets/UI 2D/toggle_annotations_on.png")
@onready var annotations_off_icon = preload("res://assets/UI 2D/toggle_annotations_off.png")

var is_on : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _pressed():
	is_on = not is_on
	
	if is_on:
		icon = annotations_on_icon
		AnnotationsManager.make_material()
	else:
		icon = annotations_off_icon
		AnnotationsManager.make_immaterial()
