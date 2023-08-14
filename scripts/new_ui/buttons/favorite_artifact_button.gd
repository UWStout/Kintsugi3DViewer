extends ToggleButton

@onready var cache_artifact_display = $"../../../.."

var favorited_icon = preload("res://assets/UI 2D/Icons/Favorites/FavoritesFavorited_White_V2.svg")
var not_favorited_icon = preload("res://assets/UI 2D/Icons/Favorites/FavoritesUnfavorited_White_V2.svg")

@onready var texture_rect = $CenterContainer/TextureRect



func _on_toggle_on():
	CacheManager.make_persistent(cache_artifact_display.artifact_url_name)
	display_favorited()
	super._on_toggle_on()

func _on_toggle_off():
	CacheManager.make_not_persistent(cache_artifact_display.artifact_url_name)
	display_not_favorited()
	super._on_toggle_off()

func display_favorited():
	texture_rect.texture = favorited_icon

func display_not_favorited():
	texture_rect.texture = not_favorited_icon
