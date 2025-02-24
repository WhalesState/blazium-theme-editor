@tool
extends Window

const DATA_PATH := "res://addons/blazium_theme_editor/editor/data.cfg"
const ICONS_DIR := "res://addons/blazium_theme_editor/editor/icons/filled"
const ICONS_PATH := "gui/theme/user_icons"

var def_theme := ThemeDB.get_default_theme()

@onready var icons_container: HFlowContainer = $"%IconsContainer"
@onready var selected_container: HFlowContainer = $"%SelectedContainer"
@onready var search_box: LineEdit = $"%SearchBox"
@onready var icon_preview: TextureRect = $"%IconPreview"
@onready var icon_label: Label = $"%IconLabel"
@onready var use_accent_color: CheckButton = $"%UseAccentColor"
@onready var size_box: HBoxContainer = $"%SizeBox"
@onready var save_button: Button = $"%SaveButton"

var spin_slider := EditorSpinSlider.new()
var selected_icons := {}
var cfg := ConfigFile.new()

var selected : IconButton:
	set(value):
		selected = value
		if selected:
			_update_icon()
			icon_label.text = selected.tooltip_text


func _update_icon():
	if not selected:
		return
	var col_str: String = "accent" if selected.use_accent else "font"
	var col: Color = def_theme.get_color("%s_color" % col_str, "Colors")
	icon_preview.texture = selected.generate_texture("#%s" % col.to_html(false), selected.icon_size, 2)


func _ready() -> void:
	if is_part_of_edited_scene():
		return
	if FileAccess.file_exists(DATA_PATH):
		cfg.load(DATA_PATH)
		selected_icons = cfg.get_value("data", "selected_icons", {})
	else:
		cfg.set_value("data", "selected_icons", selected_icons)
		cfg.save(DATA_PATH)
	save_button.pressed.connect(_on_save_button_pressed)
	var pnl: Panel = get_child(0) as Panel
	pnl.add_theme_stylebox_override("panel", EditorInterface.get_editor_theme().get_stylebox("PanelForeground", "EditorStyles"))
	search_box.right_icon = EditorInterface.get_editor_theme().get_icon("Search", "EditorIcons")
	var icons_dir := DirAccess.open(ProjectSettings.globalize_path(ICONS_DIR))
	var sources = icons_dir.get_files()
	for icon_file in sources:
		var source = FileAccess.get_file_as_string(ICONS_DIR.path_join(icon_file))
		var icon_button := IconButton.new(icon_file, source)
		icons_container.add_child(icon_button)
		icon_button.focus_entered.connect(_on_icon_selected.bind(icon_button.get_index()))
		if selected_icons.has(icon_file):
			icon_button.icon_size = selected_icons[icon_file][0]
			icon_button.use_accent = selected_icons[icon_file][1]
			_add_to_selected_icons(icon_button)
			icon_button.set_pressed_no_signal(true)
	update_selected_icons.call_deferred()
	use_accent_color.toggled.connect(_on_use_accent_toggled)
	close_requested.connect(hide)
	spin_slider.min_value = 16
	spin_slider.max_value = 64
	spin_slider.step = 8
	spin_slider.value = 16
	spin_slider.suffix = "px"
	spin_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_box.add_child(spin_slider)
	spin_slider.value_changed.connect(_change_icon_size)
	min_size = Vector2(320, 320)
	icons_container.get_child(0).grab_focus()
	search_box.text_changed.connect(_filter_icons)


func _filter_icons(new_text: String):
	new_text = new_text.to_lower().replace(" ", "_")
	if new_text.is_empty():
		for child: IconButton in icons_container.get_children():
			child.show()
		return
	for child: IconButton in icons_container.get_children():
		child.visible = child.tooltip_text.contains(new_text)


func _focus_icon(idx: int):
	icons_container.get_child(idx).grab_focus()


func _change_icon_size(new_size: float):
	if not selected:
		return
	selected.icon_size = new_size
	_update_icon()


func _on_icon_selected(idx: int):
	selected = icons_container.get_child(idx)
	use_accent_color.set_pressed_no_signal(selected.use_accent)
	spin_slider.set_value_no_signal(selected.icon_size)


func _on_save_button_pressed():
	for child: TextureRect in selected_container.get_children():
		selected_container.remove_child(child)
		child.free()
	selected_icons.clear()
	var generated := {}
	for child: IconButton in icons_container.get_children():
		if not child.button_pressed:
			continue
		_add_to_selected_icons(child)
		generated[child.tooltip_text] = child.get_generated_source()
	cfg.set_value("data", "selected_icons", selected_icons)
	cfg.save(DATA_PATH)
	var plugin := BlaziumThemePlugin.singleton
	plugin.update_generated_icons(generated)
	update_selected_icons()
	ThemeDB.icons_changed.emit()
	print(ThemeDB.get_user_icon_list())


func update_selected_icons():
	for child: TextureRect in selected_container.get_children():
		child.texture = ThemeDB.get_user_icon(child.tooltip_text)
	_update_icon.call_deferred()


func _add_to_selected_icons(selected: IconButton):
	var tex := SelectedIcon.new(selected.get_index())
	tex.select_icon.connect(_focus_icon)
	tex.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var tooltip: String = selected.tooltip_text
	selected_icons[tooltip] = [selected.icon_size, selected.use_accent]
	tex.tooltip_text = tooltip
	selected_container.add_child(tex)


func _on_use_accent_toggled(enabled: bool):
	if not selected:
		return
	selected.use_accent = enabled
	_update_icon()


class SelectedIcon extends TextureRect:
	signal select_icon(icon_index: int)

	var idx := -1


	func _gui_input(event: InputEvent) -> void:
		if not event is InputEventMouseButton:
			return
		if not (event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed()):
			return
		select_icon.emit(idx)


	func _init(_idx: int) -> void:
		idx = _idx


class IconButton extends Button:
	var source := ""
	var use_accent := false
	var icon_size := 16


	func _init(icon_name: String, icon_source: String) -> void:
		name = icon_name.capitalize()
		toggle_mode = true
		tooltip_text = icon_name
		var pos := icon_source.findn("\"0 0 24 24\"")
		var new_str = "width=\"%d\" height=\"%d\""
		icon_source = icon_source.replacen("width=\"24\" height=\"24\"", new_str)
		icon_source = icon_source.insert(pos + 11, " fill=\"%s\"")
		source = icon_source
		icon = generate_texture("white", 24, 2)


	func _gui_input(event: InputEvent) -> void:
		if not event is InputEventMouseButton:
			return
		if not (event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed()):
			return
		grab_focus()


	func generate_texture(fill_color: String, base_size: int, scale: float) -> ImageTexture:
		var icon_source = source % [base_size, base_size, fill_color]
		var img := Image.new()
		img.load_svg_from_string(icon_source, scale)
		img.fix_alpha_edges()
		return ImageTexture.create_from_image(img)


	func get_generated_source() -> String:
		return source % [icon_size, icon_size, "#0f0" if use_accent else "red"]
