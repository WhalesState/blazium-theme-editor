@tool
class_name ThemeEditor
extends Window

const COLORS: PackedStringArray = [
	"base_color",
	"accent_color",
	"accent_color2",
	"bg_color",
	"bg_color2",
	"normal_color",
	"hover_color",
	"pressed_color",
	"disabled_color",
	"font_color",
	"mono_color",
	"font_outline_color",
]

var def := ThemeDB.get_default_theme()
var fonts := {}

static var singleton: ThemeEditor

@onready var inspector: ThemeInspector = $"%ThemeInspector"
@onready var preview_panel: Panel = $"%PreviewPanel"
@onready var colors_box: HBoxContainer = $"%ColorsBox"
@onready var picker_panel: PopupPanel = $"%ColorPickerPanel"
@onready var font_options: OptionButton = $"%FontOptions"
@onready var preset_options: OptionButton = $"%PresetOptions"


func _ready() -> void:
	if Engine.is_editor_hint() and is_part_of_edited_scene():
		return
	for color_name: String in COLORS:
		var rect := ColorRect.new()
		rect.name = color_name.capitalize()
		rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rect.color = get_color(color_name)
		rect.tooltip_text = color_name.capitalize()
		colors_box.add_child(rect)

	close_requested.connect(hide)
	preview_panel.theme = ThemeDB.get_default_theme()
	if Engine.is_editor_hint():
		inspector.add_theme_stylebox_override("panel", EditorInterface.get_editor_theme().get_stylebox("PanelForeground", "EditorStyles"))
	else:
		theme = ThemeDB.get_default_theme().duplicate(true)
	for i in fonts.size():
		var icon_name: String = fonts.keys()[i]
		font_options.add_item(icon_name, i)
		var font_path: String = fonts[icon_name]
		font_options.set_item_metadata(i, font_path)
		if font_path == get_setting("custom_font"):
			font_options.select(i)
	font_options.item_selected.connect(_on_font_selected)
	update_properties()


func update_properties():
	if not inspector:
		return

	inspector.clear()

	inspector.property("colors/base_color", get_setting("base_color"),
			"edit_alpha:false")
	inspector.property("colors/accent_color", get_setting("accent_color"),
			"edit_alpha:false")
	inspector.property("constants/margin", get_setting("margin"),
			"min_value:0 max_value:16 step:1 suffix:px")
	inspector.property("constants/padding", get_setting("padding"),
			"min_value:0 max_value:16 step:1 suffix:px")
	inspector.property("constants/border_width", get_setting("border_width"),
			"min_value:0 max_value:16 step:1 suffix:px")
	inspector.property("constants/corner_radius", get_setting("corner_radius"),
			"min_value:0 max_value:16 step:1 suffix:px")
	inspector.property("constants/default_theme_scale", get_setting("default_theme_scale"),
			"min_value:0 max_value:8 step:0.1", "Scale")
	inspector.property("contrast/contrast", get_setting("contrast"),
			"min_value:-1.0 max_value:1.0 step:0.01")
	inspector.property("contrast/normal_contrast", get_setting("normal_contrast"),
			"min_value:-1.0 max_value:1.0 step:0.01")
	inspector.property("contrast/hover_contrast", get_setting("hover_contrast"),
			"min_value:-1.0 max_value:1.0 step:0.01")
	inspector.property("contrast/pressed_contrast", get_setting("pressed_contrast"),
			"min_value:-1.0 max_value:1.0 step:0.01")
	inspector.property("contrast/bg_contrast", get_setting("bg_contrast"),
			"min_value:-1.0 max_value:1.0 step:0.01")
	inspector.property("font/font_color_override", get_setting("font_color_override"),
			"enum:Auto,Light,Dark,Custom", "Color Override")
	inspector.property("font/custom_font_color", get_setting("custom_font_color"),
			"edit_alpha:false", "Custom Color")
	inspector.property("font/font_outline_color", get_setting("font_outline_color"),
			"", "Outline Color")
	inspector.property("font/font_size", get_setting("font_size"),
			"min_value:8 max_value:32 step:1 suffix:px", "Size")
	inspector.property("font/font_embolden", get_setting("font_embolden"),
			"min_value:-2.0 max_value:2.0 step:0.1 suffix:px", "Embolden")
	inspector.property("font/font_outline_size", get_setting("font_outline_size"),
			"min_value:0 max_value:32 step:1 suffix:px", "Outline Size")
	inspector.property("font_spacing/font_spacing_glyph", get_setting("font_spacing_glyph"),
			"min_value:-32 max_value:32 step:1 suffix:px", "Spacing Glyph")
	inspector.property("font_spacing/font_spacing_space", get_setting("font_spacing_space"),
			"min_value:-32 max_value:32 step:1 suffix:px", "Spacing Space")
	inspector.property("font_spacing/font_spacing_top", get_setting("font_spacing_top"),
			"min_value:-32 max_value:32 step:1 suffix:px", "Spacing Top")
	inspector.property("font_spacing/font_spacing_bottom", get_setting("font_spacing_bottom"),
			"min_value:-32 max_value:32 step:1 suffix:px", "Spacing Bottom")
	inspector.property("font_advanced/default_font_subpixel_positioning", get_setting("default_font_subpixel_positioning"),
			"enum:Disabled,Auto,Half Pixel,Quarter Pixel", "Sub-Pixel Positioning")
	inspector.property("font_advanced/default_font_antialiasing", get_setting("default_font_antialiasing"),
			"enum:None,Grayscale,LCD Subpixel", "Anti-Aliasing")
	inspector.property("font_advanced/lcd_subpixel_layout", get_setting("lcd_subpixel_layout"),
			"enum:Disabled,Horizontal RGB,Horizontal BGR, Vertical RGB, Vertical BGR", "LCD SubPixel Layout")
	inspector.property("font_advanced/default_font_hinting", get_setting("default_font_hinting"),
			"enum:None,Light,Normal", "Font Hinting")
	inspector.property("font_advanced/default_font_multichannel_signed_distance_field",
			get_setting("default_font_multichannel_signed_distance_field"),
			"", "Use MSDF")
	inspector.property("font_advanced/default_font_generate_mipmaps",
			get_setting("default_font_generate_mipmaps"),
			"", "Generate Mipmaps")


func _on_font_selected(item_idx: int):
	var font_path: String = font_options.get_item_metadata(item_idx)
	ProjectSettings.set_setting("gui/theme/custom_font", font_options.get_item_metadata(item_idx))


func _init() -> void:
	if is_part_of_edited_scene():
		return
	singleton = self
	ThemeDB.colors_changed.connect(colors_changed)
	var path := "res://addons/blazium_theme_editor/fonts"
	fonts["Default"] = ""
	for file in DirAccess.get_files_at(path):
		if file.get_extension() != "ttf":
			continue
		fonts[file.get_basename().capitalize()] = path.path_join(file)


func clear() -> void:
	if is_part_of_edited_scene():
		return
	singleton = null
	ThemeDB.colors_changed.disconnect(colors_changed)


func _notification(what: int) -> void:
	if Engine.is_editor_hint() and is_part_of_edited_scene():
		return
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			update_properties()
		else:
			# Note: In game, you will need to save and load your settings.
			ProjectSettings.save()


func get_color(property: String) -> Color:
	return def.get_color(property, "Colors")


func get_const(property: String) -> float:
	return def.get_constant(property, "Constants")


func get_setting(setting: String) -> Variant:
	return ProjectSettings.get_setting("gui/theme/%s" % setting)


func get_theme_scale():
	return def.get_default_base_scale()


func colors_changed():
	if not colors_box or colors_box.get_child_count() != COLORS.size():
		return
	for i in COLORS.size():
		var color_name := COLORS[i]
		var rect: ColorRect = colors_box.get_node(color_name.capitalize())
		rect.color = get_color(color_name)
