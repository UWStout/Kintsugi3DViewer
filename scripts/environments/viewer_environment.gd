class_name ViewerEnvironnment extends WorldEnvironment

# Graphics settings
var sdfgi_enabled : bool
var ssao_enabled : bool
var ssil_enabled : bool
var ssr_enabled : bool
var cam

func _on_environment_changed(new_environment : DisplayEnvironment):
	# Set current "environment" (i.e. background graphics) to the one defined 
	# for the new environment scene.
	self.environment = new_environment.environment_graphics
	
	# Apply global graphics settings
	refresh_graphics_settings()

func refresh_graphics_settings():
	if (self.environment != null):
		self.environment.sdfgi_enabled = sdfgi_enabled
		self.environment.ssao_enabled = ssao_enabled
		self.environment.ssil_enabled = ssil_enabled
		self.environment.ssr_enabled = ssr_enabled

func change_global_illumination(mode : GraphicsController.GLOBAL_ILLUMINATION):
	if (self.environment != null):
		if mode > 0:
			sdfgi_enabled = true
			self.environment.sdfgi_enabled = true
		else:
			sdfgi_enabled = false
			self.environment.sdfgi_enabled = false

func change_ssao(mode : GraphicsController.SSAO):
	if (self.environment != null):
		ssao_enabled = true
		self.environment.ssao_enabled = true

func change_ssil(mode : GraphicsController.SSIL):
	if (self.environment != null):
		if mode < 0:
			ssil_enabled = false
			self.environment.ssil_enabled = false
		else:
			ssil_enabled = true
			self.environment.ssil_enabled = true

func change_ssr(mode : GraphicsController.SSR):
	if (self.environment != null):
		if mode == 0:
			ssr_enabled = false
			self.environment.ssr_enabled = false
		elif mode > 0:
			ssr_enabled = true
			self.environment.ssr_enabled = true
