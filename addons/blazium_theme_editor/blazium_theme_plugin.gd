@tool
class_name BlaziumThemePlugin
extends EditorPlugin

const ICONS_PATH := "gui/theme/user_icons"

var icons_editor: Window
var theme_editor: ThemeEditor
var user_icons := PackedStringArray()
static var singleton: BlaziumThemePlugin


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		icons_editor = preload("./editor/tools/icons_editor.tscn").instantiate()
		icons_editor.hide()
		EditorInterface.get_base_control().add_child(icons_editor)
		add_tool_menu_item("Blazium Icons Editor", _show_icons_editor)
		theme_editor = preload("res://addons/blazium_theme_editor/editor/tools/theme_editor.tscn").instantiate()
		theme_editor.hide()
		EditorInterface.get_base_control().add_child(theme_editor)
		add_tool_menu_item("Blazium Theme Editor", _show_theme_editor)
		ThemeDB.icons_changed.connect(_update_icons)

	if not ProjectSettings.has_setting(ICONS_PATH):
		ProjectSettings.set_setting(ICONS_PATH, {})
		ProjectSettings.save()

	update_generated_icons(ProjectSettings.get_setting(ICONS_PATH, {}))
	singleton = self
	add_autoload_singleton.call_deferred("UserIconsLoader", "res://addons/blazium_theme_editor/user_icons_loader.gd")


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		EditorInterface.get_base_control().remove_child(icons_editor)
		icons_editor.free()
		icons_editor = null
		remove_tool_menu_item("Blazium Icons Editor")
		EditorInterface.get_base_control().remove_child(theme_editor)
		theme_editor.free()
		theme_editor = null
		remove_tool_menu_item("Blazium Theme Editor")
		ThemeDB.icons_changed.disconnect(_update_icons)
	clear_user_icons()
	singleton = null
	remove_autoload_singleton("UserIconsLoader")


func _update_icons():
	icons_editor.update_selected_icons()


func _show_icons_editor():
	if Engine.is_editor_hint():
		icons_editor.show()


func _show_theme_editor():
	if Engine.is_editor_hint():
		theme_editor.show()


func clear_user_icons():
	for user_icon in user_icons:
		ThemeDB.remove_user_icon(user_icon)
	user_icons.clear()


func update_generated_icons(generated_icons: Dictionary):
	ProjectSettings.set_setting(ICONS_PATH, generated_icons)
	ProjectSettings.save()
	clear_user_icons()
	for icon_name in generated_icons:
		user_icons.append(icon_name)
		ThemeDB.add_user_icon(icon_name, generated_icons[icon_name])
	ThemeDB.icons_changed.emit()
