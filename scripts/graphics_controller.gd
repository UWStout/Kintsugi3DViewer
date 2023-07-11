extends Node

enum SHADOWS {HARD = 0, SOFT_LOW = 2, SOFT_MEDIUM = 3, SOFT_HIGH = 4, SOFT_ULTRA = 5}
enum GLOBAL_ILLUMINATION {LOW, MEDIUM, HIGH, ULTRA}
const GLOBAL_ILLUMINATION_SETTINGS = {
	"key" : "value",
	0 : [0, 16],
	1 : [0, 32],
	2 : [1, 32],
	3 : [1, 64]
}
enum BLOOM {OFF, SSAO_LOW, SSAO_HIGH}

@export var world_environment : WorldEnvironment
@export var aa_settings : Viewport.MSAA

func change_resolution(new_res : Vector2i):
	get_tree().root.set_min_size(new_res)

func change_shadows(mode : SHADOWS):
	ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", mode)
	ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality.mobile", mode)
	
	ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality", mode)
	ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality.mobile", mode)

func change_global_illumination(mode : GLOBAL_ILLUMINATION):
	
	pass

func change_antialiasing(mode : Viewport.MSAA):
	get_viewport().msaa_3d = mode



func _ready():
	change_resolution(Vector2i(1152, 648))
