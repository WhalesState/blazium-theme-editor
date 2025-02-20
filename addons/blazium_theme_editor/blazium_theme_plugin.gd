@tool
class_name BlaziumThemePlugin
extends EditorPlugin

const GENERATED_PATH := "res://addons/blazium_theme_editor/icons.cfg"

var icons_editor: Window
var gen := ConfigFile.new()
var user_icons := PackedStringArray()
var theme_generator: ThemeGenerator

static var singleton: BlaziumThemePlugin


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		icons_editor = preload("./editor/icons_editor.tscn").instantiate()
		icons_editor.hide()
		EditorInterface.get_base_control().add_child(icons_editor)
		add_tool_menu_item("Blazium Icons Editor", _show_icons_editor)
		ThemeDB.icons_changed.connect(_update_icons)
	if FileAccess.file_exists(GENERATED_PATH):
		gen.load(GENERATED_PATH)
	else:
		gen.set_value("data", "generated_icons", {})
		gen.save(GENERATED_PATH)
	update_generated_icons(gen.get_value("data", "generated_icons"))
	singleton = self
	theme_generator = ThemeGenerator.new()


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		EditorInterface.get_base_control().remove_child(icons_editor)
		icons_editor.free()
		icons_editor = null
		remove_tool_menu_item("Blazium Icons Editor")
		ThemeDB.icons_changed.disconnect(_update_icons)
	clear_user_icons()
	singleton = null
	theme_generator.clear()
	theme_generator.free()
	theme_generator = null


func _update_icons():
	icons_editor.update_selected_icons()


func _show_icons_editor():
	if Engine.is_editor_hint():
		icons_editor.show()


func clear_user_icons():
	for user_icon in user_icons:
		ThemeDB.remove_user_icon(user_icon)
	user_icons.clear()


func update_generated_icons(generated_icons: Dictionary):
	gen.set_value("data", "generated_icons", generated_icons)
	gen.save(GENERATED_PATH)
	clear_user_icons()
	for icon_name in generated_icons:
		user_icons.append(icon_name)
		ThemeDB.add_user_icon(icon_name, generated_icons[icon_name])
	ThemeDB.icons_changed.emit()
