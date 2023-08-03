extends Control

@onready var label = $VBoxContainer/MarginContainer2/Label
@onready var option_button = $VBoxContainer/cache_mode_button/HBoxContainer2/MarginContainer/OptionButton

@export var cache_ui : CacheUI

func _ready():
	option_button.select(CacheManager.cache_mode)
	change_text(CacheManager.cache_mode)

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


func _on_option_button_item_selected(index):
	CacheManager.set_cache_mode(index)
	change_text(index)
	
	if not cache_ui == null:
		cache_ui.refresh_list()
