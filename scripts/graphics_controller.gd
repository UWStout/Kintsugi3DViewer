# Copyright (c) 2023 Michael Tetzlaff, Tyler Betanski, Jacob Buelow, Victor Mondragon, Isabel Smith
#
# Licensed under GPLv3
# ( http://www.gnu.org/licenses/gpl-3.0.html )
#
# This code is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

class_name GraphicsController extends Node

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
	
	Preferences.write_pref("shadows", mode)

func change_global_illumination(mode : GLOBAL_ILLUMINATION):
	if mode > 0:
		world_environment.environment.sdfgi_enabled = true
	else:
		world_environment.environment.sdfgi_enabled = false
	
	var quality = GLOBAL_ILLUMINATION_SETTINGS.get(mode)[0]
	var ray_count = GLOBAL_ILLUMINATION_SETTINGS.get(mode)[1]
	
	ProjectSettings.set_setting("rendering/global_illumination/voxel_gi/quality", quality)
	ProjectSettings.set_setting("rendering/global_illumination/sdfgi/probe_ray_count", ray_count)
	
	Preferences.write_pref("gi", mode)

func change_antialiasing(mode : Viewport.MSAA):
	get_viewport().msaa_3d = mode
	
	Preferences.write_pref("aa", mode)

func change_ssao(mode : SSAO):
	world_environment.environment.ssao_enabled = true
	ProjectSettings.set_setting("rendering/environment/ssao/quality", mode)
	
	Preferences.write_pref("ssao", mode)

func change_ssil(mode : SSIL):
	if mode < 0:
		world_environment.environment.ssil_enabled = false
	else:
		world_environment.environment.ssil_enabled = true
	
	ProjectSettings.set_setting("rendering/environment/ssil/quality", mode)
	
	Preferences.write_pref("ssil", mode)

func change_ssr(mode : SSR):
	if mode == 0:
		world_environment.environment.ssr_enabled = false
	elif mode > 0:
		world_environment.environment.ssr_enabled = true
	
	ProjectSettings.set_setting("rendering/environment/screen_space_reflection/roughness_quality", mode)
	
	Preferences.write_pref("ssr", mode)

func change_subsurface_scattering(mode : SUBSURFACE):
	ProjectSettings.set_setting("rendering/environment/subsurface_scattering/subsurface_scattering_quality", mode)
	
	Preferences.write_pref("subsurface scattering", mode)

func _ready():
	shadows = Preferences.read_pref("shadows")
	antialiasing = Preferences.read_pref("aa")
	global_illumination = Preferences.read_pref("gi")
	ssao = Preferences.read_pref("ssao")
	#ssil = Preferences.read_pref("ssil")
	#screen_space_reflections = Preferences.read_pref("ssr")
	#subsurface_scattering = Preferences.read_pref("subsurface scattering")
	
	change_resolution(Vector2i(1152, 648))
	change_shadows(shadows)
	change_global_illumination(global_illumination)
	change_antialiasing(antialiasing)
	change_ssao(ssao)
	#change_ssil(ssil)
	#change_ssr(screen_space_reflections)
	#change_subsurface_scattering(subsurface_scattering)
