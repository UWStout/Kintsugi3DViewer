@tool extends WorldEnvironment

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		self.environment = self.get_parent().environment_graphics
