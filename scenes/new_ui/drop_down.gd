extends OptionButton


func _ready():
	var popup_menu: PopupMenu = get_popup()

	# Loop through all items in the dropdown
	for i in popup_menu.get_item_count():
		# Check if the item is set to use radio buttons
		if popup_menu.is_item_radio_checkable(i):
			# Disable the radio icon
			popup_menu.set_item_as_radio_checkable(i, false)
