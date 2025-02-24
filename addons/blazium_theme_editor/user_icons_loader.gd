extends Node


func _init() -> void:
	var icons_path := BlaziumThemePlugin.singleton.ICONS_PATH
	var icons: Dictionary = ProjectSettings.get_setting(icons_path, {})
	for icon in icons:
		ThemeDB.add_user_icon(icon, icons[icon])
