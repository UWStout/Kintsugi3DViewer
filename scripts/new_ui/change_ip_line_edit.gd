extends LineEdit

@onready var owner_node = $"../../.."

func _ready():
	if not Preferences.read_pref("allow ip change"):
		owner_node.visible = false
	else:
		var read_text = Preferences.read_pref("ip")
		if not read_text == null:
			text = read_text

func _on_text_changed(new_text):
	Preferences.write_pref("ip", new_text)
