@tool
extends Control

const BASE_COLOR := "base_color"
const ACCENT_COLOR := "accent_color"
const ACCENT_COLOR_2 := "accent_color2"
const BG_COLOR := "bg_color"
const BG_COLOR_2 := "bg_color2"
const FONT_COLOR := "font_color"
const MONO_COLOR := "mono_color"
const FONT_OUTLINE_COLOR := "font_outline_color"
const NORMAL_COLOR := "normal_color"
const HOVER_COLOR := "hover_color"
const PRESSED_COLOR := "pressed_color"
const DISABLED_COLOR := "disabled_color"

const CONST_MARGIN := "margin"
const CONST_PADDING := "padding"
const CONST_BORDER_WIDTH := "border_width"
const CONST_CORNER_RADIUS := "corner_radius"
const CONST_BORDER_PADDING := "border_padding"
const CONST_FOCUS_CORNERS := "focus_corners"
const CONST_FONT_OUTLINE_SIZE := "font_outline_size"

var def := ThemeDB.get_default_theme()


func colors_changed():
	var base_color = get_color(BASE_COLOR)
	var accent_color = get_color(ACCENT_COLOR)
	var accent_color2 = get_color(ACCENT_COLOR_2)
	var bg_color = get_color(BG_COLOR)
	var bg_color2 = get_color(BG_COLOR_2)
	var font_color = get_color(FONT_COLOR)
	var hover_color = get_color(HOVER_COLOR)
	var normal_color = get_color(NORMAL_COLOR)
	var pressed_color = get_color(PRESSED_COLOR)
	var disabled_color = get_color(DISABLED_COLOR)
	var font_outline_color = get_color(FONT_OUTLINE_COLOR)
	var mono_color = get_color(MONO_COLOR)


func icons_changed():
	var base_scale := get_theme_scale()
	var font_color := get_color(FONT_COLOR)
	var accent_color := get_color(ACCENT_COLOR)


func font_color_changed():
	var font_color := get_color(FONT_COLOR)


func scale_changed():
	var base_scale := get_theme_scale()


func margin_changed():
	var margin := get_const(CONST_MARGIN)


func padding_changed():
	var padding := get_const(CONST_PADDING)


func font_size_changed():
	var font_size := def.get_default_font_size()


func border_width_changed():
	var border_width := get_const(CONST_BORDER_WIDTH)


func corner_radius_changed():
	var corner_radius := get_const(CONST_CORNER_RADIUS)
	var focus_corners := get_const(CONST_FOCUS_CORNERS)


func border_padding_changed():
	var border_padding := get_const(CONST_BORDER_PADDING)


func font_outline_size_changed():
	var font_outline_size := get_const(CONST_FONT_OUTLINE_SIZE)


func font_outline_color_changed():
	var font_color_color := get_color(FONT_OUTLINE_COLOR)


func get_color(property: String) -> Color:
	return def.get_color(property, "Colors")


func get_const(property: String) -> float:
	return def.get_constant(property, "Constants")


func get_theme_scale() -> float:
	return def.get_default_base_scale()


func _enter_tree() -> void:
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
	ThemeDB.font_outline_color_changed.connect(font_outline_color_changed)


func _exit_tree() -> void:
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
	ThemeDB.font_outline_color_changed.disconnect(font_outline_color_changed)
