extends StaticBody3D

class_name MovableSpotlight

var controller : MovableLightingController

var angle : float = 0
var radius : float = 0
var height : float = 0

var connected_light : DirectionalLight3D

# Always look towards the world origin, which is approximately the
# angle of the world light
func _process(delta):
	look_at(Vector3(0,0,0))

# modify the material to look like the light it represents
func set_color(new_color : Color, energy_percent : float):
	if not $mesh == null:
		var mat = StandardMaterial3D.new()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = new_color
		mat.albedo_color.a = (energy_percent)
		mat.emission_enabled = true
		mat.emission = new_color
		mat.emission_energy_multiplier = 1
		
		$mesh.set_surface_override_material(0, mat)

func update_angle(new_angle : float):
	angle = new_angle
	
	if not connected_light == null:
		connected_light.rotation_degrees.y = angle
	
	position = Vector3(sin(deg_to_rad(angle)) * radius, height, cos(deg_to_rad(angle)) * radius)
