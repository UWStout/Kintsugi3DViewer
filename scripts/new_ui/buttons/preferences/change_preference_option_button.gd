extends OptionButton

@export var preference : String

func _ready():
	select(Preferences.read_pref(preference))

func _on_item_selected(index):
	Preferences.write_pref(preference, index)
