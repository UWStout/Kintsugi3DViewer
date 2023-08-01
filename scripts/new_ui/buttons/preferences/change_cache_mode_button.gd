extends OptionButton

@onready var label = $"../../../../MarginContainer2/Label"

func _ready():
	select(Preferences.read_pref("cache mode"))
	change_text(Preferences.read_pref("cache mode"))

func _on_item_selected(index):
	Preferences.write_pref("cache mode", index)
	change_text(index)


func change_text(index : int):
	if index == 0:
		label.text = "When the cache is oversized, the largest objects will be removed first."
	elif index == 1:
		label.text = "When the cache is oversized, the smallest objects will be removed first."
	elif index == 2:
		label.text = "When the cache is oversized, the most recently opened artifacts will be removed first."
	elif index == 3:
		label.text = "When the cache is oversized, the least recently opened artifacts will be removed first. [DEFAULT]"
	else:
		label.text = ""
