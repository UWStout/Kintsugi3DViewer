extends Node

enum ASPECT_RATIO {_4to3, _16to10, _16to9}

const _4x3_RESOULATIONS = [
	Vector2i(640, 480),
	Vector2i(800, 600),
	Vector2i(960, 720),
	Vector2i(1024, 768),
	Vector2i(1280, 960),
	Vector2i(1400, 1050),
	Vector2i(1440, 1080),
	Vector2i(1600, 1200),
	Vector2i(1856, 1392),
	Vector2i(1920, 1440),
	Vector2i(2048, 1536) ]
const _16x10_RESOLUTIONS = [
	Vector2i(1280, 800),
	Vector2i(1440, 900),
	Vector2i(1680, 1050),
	Vector2i(1920, 1200),
	Vector2i(2560, 1600) ]
const _16x9_RESOLUTIONS = [
	Vector2i(1024, 576),
	Vector2i(1152, 648),
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160),
	Vector2i(7680, 4320) ]
const RESOLUTIONS = [_16x9_RESOLUTIONS, _16x10_RESOLUTIONS, _4x3_RESOULATIONS]

enum SHADOWS {HARD = 0, SOFT_LOW = 2, SOFT_MEDIUM = 3, SOFT_HIGH = 4, SOFT_ULTRA = 5}

enum GLOBAL_ILLUMINATION {DISABLED, LOW, MEDIUM, HIGH, ULTRA}
const GLOBAL_ILLUMINATION_SETTINGS = {
	"key" : "value",
	0 : [0, 8],
	1 : [0, 16],
	2 : [1, 32],
	3 : [1, 64],
	4 : [1, 128] }

enum SSAO {VERY_LOW, LOW, MEDIUM, HIGH, ULTRA}

enum SSIL {DISABLED = -1, VERY_LOW = 0, LOW = 1, MEDIUM = 2, HIGH = 3, ULTRA = 4}

enum SSR {DISABLED, LOW, MEDIUM, HIGH}

enum SUBSURFACE {DISABLED, LOW, MEDIUM, HIGH}

@export var world_environment : WorldEnvironment
@export var shadows : SHADOWS = SHADOWS.SOFT_MEDIUM
@export var antialiasing : Viewport.MSAA = Viewport.MSAA_4X
@export var global_illumination : GLOBAL_ILLUMINATION = GLOBAL_ILLUMINATION.DISABLED
@export var ssao : SSAO = SSAO.MEDIUM
@export var ssil: SSIL = SSIL.DISABLED
@export var screen_space_reflections : SSR = SSR.DISABLED
@export var subsurface_scattering : SUBSURFACE = SUBSURFACE.MEDIUM

func change_resolution(new_res : Vector2i):
	get_tree().root.set_min_size(new_res)

func change_shadows(mode : SHADOWS):
	ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", mode)
	ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality.mobile", mode)
	
	ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality", mode)
	ProjectSettings.set_setting("rendering/lights_and_shadows/positional_shadow/soft_shadow_filter_quality.mobile", mode)

func change_global_illumination(mode : GLOBAL_ILLUMINATION):
	if mode > 0:
		world_environment.environment.sdfgi_enabled = true
	else:
		world_environment.environment.sdfgi_enabled = false
	
	var quality = GLOBAL_ILLUMINATION_SETTINGS.get(mode)[0]
	var ray_count = GLOBAL_ILLUMINATION_SETTINGS.get(mode)[1]
	
	ProjectSettings.set_setting("rendering/global_illumination/voxel_gi/quality", quality)
	ProjectSettings.set_setting("rendering/global_illumination/sdfgi/probe_ray_count", ray_count)

func change_antialiasing(mode : Viewport.MSAA):
	get_viewport().msaa_3d = mode

func change_ssao(mode : SSAO):
	world_environment.environment.ssao_enabled = true
	ProjectSettings.set_setting("rendering/environment/ssao/quality", mode)
	pass

func change_ssil(mode : SSIL):
	if mode < 0:
		world_environment.environment.ssil_enabled = false
	else:
		world_environment.environment.ssil_enabled = true
	
	ProjectSettings.set_setting("rendering/environment/ssil/quality", mode)

func change_ssr(mode : SSR):
	if mode == 0:
		world_environment.environment.ssr_enabled = false
	elif mode > 0:
		world_environment.environment.ssr_enabled = true
	
	ProjectSettings.set_setting("rendering/environment/screen_space_reflection/roughness_quality", mode)

func change_subsurface_scattering(mode : SUBSURFACE):
	ProjectSettings.set_setting("rendering/environment/subsurface_scattering/subsurface_scattering_quality", mode)

func _ready():
	change_resolution(Vector2i(1152, 648))
	change_shadows(shadows)
	change_global_illumination(global_illumination)
	change_antialiasing(antialiasing)
	change_ssao(ssao)
	change_ssil(ssil)
	change_ssr(screen_space_reflections)
	change_subsurface_scattering(subsurface_scattering)
