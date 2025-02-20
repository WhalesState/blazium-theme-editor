@tool
class_name ThemeGenerator
extends Object

var def_theme := ThemeDB.get_default_theme()
static var singleton: ThemeGenerator


func _init() -> void:
	singleton = self
	ThemeDB.colors_changed.connect(colors_changed)
	ThemeDB.icons_changed.connect(icons_changed)
	ThemeDB.scale_changed.connect(scale_changed)
	ThemeDB.margin_changed.connect(margin_changed)
	ThemeDB.padding_changed.connect(padding_changed)
	ThemeDB.font_size_changed.connect(font_size_changed)
	ThemeDB.font_color_changed.connect(font_color_changed)
	ThemeDB.border_width_changed.connect(border_width_changed)
	ThemeDB.corner_radius_changed.connect(corner_radius_changed)
	ThemeDB.border_padding_changed.connect(border_padding_changed)
	ThemeDB.font_outline_size_changed.connect(font_outline_size_changed)


func clear() -> void:
	singleton = null
	ThemeDB.colors_changed.disconnect(colors_changed)
	ThemeDB.icons_changed.disconnect(icons_changed)
	ThemeDB.scale_changed.disconnect(scale_changed)
	ThemeDB.margin_changed.disconnect(margin_changed)
	ThemeDB.padding_changed.disconnect(padding_changed)
	ThemeDB.font_size_changed.disconnect(font_size_changed)
	ThemeDB.font_color_changed.disconnect(font_color_changed)
	ThemeDB.border_width_changed.disconnect(border_width_changed)
	ThemeDB.corner_radius_changed.disconnect(corner_radius_changed)
	ThemeDB.border_padding_changed.disconnect(border_padding_changed)
	ThemeDB.font_outline_size_changed.disconnect(font_outline_size_changed)


func colors_changed():
	var base_color := def_theme.get_color("base_color", "Colors")
	var accent_color := def_theme.get_color("accent_color", "Colors")
	var accent_color2 := def_theme.get_color("accent_color2", "Colors")
	var bg_color := def_theme.get_color("bg_color", "Colors")
	var bg_color2 := def_theme.get_color("bg_color2", "Colors")
	var normal_color := def_theme.get_color("normal_color", "Colors")
	var pressed_color := def_theme.get_color("pressed_color", "Colors")
	var hover_color := def_theme.get_color("hover_color", "Colors")
	var disabled_color := def_theme.get_color("disabled_color", "Colors")
	var mono_color := def_theme.get_color("mono_color", "Colors")
	var font_color := def_theme.get_color("font_color", "Colors")
	var font_outline_color := def_theme.get_color("font_outline_color", "Colors")


func icons_changed():
	var font_color := def_theme.get_color("font_color", "Colors")
	var accent_color := def_theme.get_color("accent_color", "Colors")
	var base_scale := def_theme.get_default_base_scale()


func font_color_changed():
	var font_color := def_theme.get_color("font_color", "Colors")


func scale_changed():
	var base_scale := def_theme.get_default_base_scale()


func margin_changed():
	var margin := def_theme.get_constant("margin", "Constants")


func padding_changed():
	var padding := def_theme.get_constant("padding", "Constants")


func font_size_changed():
	var font_size := def_theme.get_default_font_size()


func border_width_changed():
	var border_width := def_theme.get_constant("border_width", "Constants")


func corner_radius_changed():
	var corner_radius := def_theme.get_constant("corner_radius", "Constants")
	var focus_corners := def_theme.get_constant("focus_corners", "Constants")


func border_padding_changed():
	var border_padding := def_theme.get_constant("border_padding", "Constants")


func font_outline_size_changed():
	var font_outline_size := def_theme.get_constant("font_outline_size", "Constants")
