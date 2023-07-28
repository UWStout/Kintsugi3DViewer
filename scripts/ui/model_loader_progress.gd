extends Control
class_name ModelLoaderProgress

#@onready var progressBar: ProgressBar = $Panel/MarginContainer/VBoxContainer/ProgressBar
@export var progressBar : ProgressBar
@export var text_label : Label

func _ready():
	end_loading()


func update_progress(progress: float):
	if not progressBar == null:
		progressBar.value = progress
	
	if not text_label == null:
		text_label.text = "LOADING (" + str((progress * 100) as int) + "%)"


func start_loading():
	show()
	update_progress(0)


func end_loading():
	hide()
