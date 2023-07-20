class_name ExtendedButton extends Button

func set_normal_style(style : StyleBox):
	if not style == null:
		remove_theme_stylebox_override("normal")
		add_theme_stylebox_override("normal", style)

func set_hover_style(style : StyleBox):
	if not style == null:
		remove_theme_stylebox_override("hover")
		add_theme_stylebox_override("hover", style)

func set_pressed_style(style : StyleBox):
	if not style == null:
		remove_theme_stylebox_override("pressed")
		add_theme_stylebox_override("pressed", style)

func set_disabled_style(style : StyleBox):
	if not style == null:
		remove_theme_stylebox_override("disabled")
		add_theme_stylebox_override("disabled", style)

func set_focus_style(style : StyleBox):
	if not style == null:
		remove_theme_stylebox_override("focus")
		add_theme_stylebox_override("focus", style)
