@tool
class_name ThemeInspector
extends Panel

var foldable_group := FoldableGroup.new()
var properties := PackedStringArray()

@onready var inspector: VBoxContainer = $"%Inspector"


func property(path: String, value: Variant, hint := "", display_name := "", default: Variant = null, tooltip := ""):
	if value == null or path.is_empty():
		return
	var path_arr := path.split("/", false, 2)
	if path_arr.size() != 2:
		return
	var grid: GridContainer
	var foldable: FoldableContainer
	for child in inspector.get_children():
		if not child is FoldableContainer:
			continue
		if child.text == path_arr[0].capitalize():
			foldable = child
			grid = child.get_child(0)
	if not grid:
		foldable = FoldableContainer.new()
		foldable.foldable_group = foldable_group
		foldable.text = path_arr[0].capitalize()
		inspector.add_child(foldable)
		grid = GridContainer.new()
		grid.columns = 3
		foldable.add_child(grid)
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_STOP
	var property_name := path.get_basename()
	label.tooltip_text = property_name.get_file()
	if display_name.is_empty():
		label.text = property_name.get_file().capitalize()
	else:
		label.text = display_name
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	if not tooltip.is_empty():
		label.tooltip_text = "%s\n%s" % [path.get_basename(), tooltip]
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(label)
	var revert := Button.new()
	var button
	match typeof(value):
		TYPE_INT:
			var enum_names := []
			if hint.begins_with("enum:"):
				enum_names.append_array(hint.replace("enum:", "").split(","))
			if not enum_names.is_empty():
				button = OptionButton.new()
				for enum_name in enum_names:
					button.add_item(enum_name)
				button.selected = value
				button.item_selected.connect(set_value.bind(property_name, button, revert))
			else:
				button = SpinBox.new()
				for _hint in hint.split(" "):
					button.set(_hint.get_slice(":", 0), _hint.get_slice(":", 1))
				button.value = value
				button.value_changed.connect(set_value.bind(property_name, button, revert))
		TYPE_FLOAT:
			button = SpinBox.new()
			for _hint in hint.split(" "):
				button.set(_hint.get_slice(":", 0), _hint.get_slice(":", 1))
			button.value = value
			button.value_changed.connect(set_value.bind(property_name, button, revert))
		TYPE_COLOR:
			button = ColorButton.new()
			button.pressed.connect(show_picker.bind(button))
			for _hint in hint.split(" "):
				button.set(_hint.get_slice(":", 0), _hint.get_slice(":", 1))
			button.color = value
			button.color_changed.connect(set_value.bind(property_name, button, revert))
		TYPE_BOOL:
			button = CheckBox.new()
			button.text = "On"
			button.button_pressed = value
			button.toggled.connect(set_value.bind(property_name, button, revert))
	revert.size_mode = BaseButton.SIZE_MODE_FIT_HEIGHT
	revert.theme_type_variation = "FlatButton"
	revert.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	revert.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if not default:
		default = value
	revert.disabled = default == value
	revert.set_meta("icon", "refresh")
	revert.icon = ThemeDB.get_user_icon("refresh")
	revert.set_meta("default", default)
	revert.icon = ThemeDB.get_icon("reload")
	revert.pressed.connect(set_value.bind(default, property_name, button, revert))
	grid.add_child(revert)
	grid.add_child(button)
	properties.append(property_name.get_file())


func show_picker(button: ColorButton):
	var rect := Rect2()
	var button_size := button.get_screen_transform().basis_xform(button.size)
	rect.position = button.get_screen_position() + Vector2(0, button_size.y)
	var picker_panel: PopupPanel = ThemeEditor.singleton.picker_panel
	var picker: ColorPicker = picker_panel.get_child(0)
	picker.set_old_color(button.color)
	picker.set_display_old_color(true)
	var callable := func(new_color: Color):
		button.color = new_color
		button.color_changed.emit(new_color)
	picker.color = button.color
	picker.color_changed.connect(callable)
	var disconnect := func():
		picker.color_changed.disconnect(callable)
	picker_panel.popup_hide.connect(disconnect, CONNECT_ONE_SHOT)
	picker_panel.popup(rect)


func set_value(value: Variant, property_name: String, button: Control, revert: Button):
	var property_path := "gui/theme/%s" % property_name.get_file()
	if not ProjectSettings.has_setting(property_path):
		return
	var force_int := false
	match typeof(ProjectSettings.get_setting(property_path)):
		TYPE_INT:
			if button is SpinBox:
				force_int = true
				var spin: SpinBox = button
				spin.set_value_no_signal(value)
			elif button is OptionButton:
				var options: OptionButton = button
				options.select(value)
		TYPE_FLOAT:
			var spin: SpinBox = button
			spin.set_value_no_signal(value)
		TYPE_COLOR:
			var color: ColorButton = button
			color.set_color(value)
		TYPE_BOOL:
			var checkbox: CheckBox = button
			checkbox.set_pressed_no_signal(value)
	if force_int:
		var int_value: int = int(value)
		ProjectSettings.set_setting(property_path, int_value)
	else:
		ProjectSettings.set_setting(property_path, value)
	if revert.visible:
		revert.disabled = revert.get_meta("default") == value


func clear():
	properties.clear()
	for child in inspector.get_children():
		inspector.remove_child(child)
		child.free()
