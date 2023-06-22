extends CenterContainer
class_name ModelLoaderProgress

@onready var progressBar: ProgressBar = $Panel/MarginContainer/VBoxContainer/ProgressBar

func _ready():
	end_loading()


func update_progress(progress: float):
	progressBar.value = progress


func start_loading():
	show()
	update_progress(0)


func end_loading():
	hide()
