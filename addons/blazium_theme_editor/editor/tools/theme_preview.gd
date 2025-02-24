@tool
extends Panel

@onready var progress: ProgressBar = $"%ProgressBar"
@onready var hslider: HSlider = $"%HSlider"
@onready var vslider: VSlider = $"%VSlider"
@onready var hscroll: HScrollBar = $"%HScrollBar"
@onready var vscroll: VScrollBar = $"%VScrollBar"
@onready var tree: Tree = $"%Tree"
@onready var tab_bar: TabBar = $"%TabBar"
@onready var tab_container: TabContainer = $"%TabContainer"


func _ready() -> void:
	# Tabs
	tab_container.current_tab = tab_bar.current_tab
	tab_bar.tab_changed.connect(tab_container.set_current_tab)
	# Slider
	hslider.share(progress)
	hslider.share(vslider)
	hscroll.share(vscroll)
	# Tree
	var root: TreeItem = tree.create_item()
	tree.set_column_title(0, "Column Title")
	root.set_text(0, "Button")
	var item: TreeItem = tree.create_item(root)
	item.set_text(0, "Item")
	var editable_item: TreeItem = tree.create_item(root)
	editable_item.set_text(0, "Editable Item")
	editable_item.set_editable(0, true)
	var sub_tree: TreeItem = tree.create_item(root)
	sub_tree.set_text(0, "Sub Tree")
	var check_item: TreeItem = tree.create_item(sub_tree)
	check_item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	check_item.set_text(0, "Check Item")
	check_item.set_editable(0, true)
	check_item.set_checked(0, true)
	var range_item: TreeItem = tree.create_item(sub_tree)
	range_item.set_cell_mode(0, TreeItem.CELL_MODE_RANGE)
	range_item.set_range_config(0, -10, 10, 0.1)
	range_item.set_editable(0, true)
	var options_item: TreeItem = tree.create_item(sub_tree)
	options_item.set_cell_mode(0, TreeItem.CELL_MODE_RANGE)
	options_item.set_editable(0, true)
	options_item.set_text(0, "Has,Many,Options")
	options_item.set_range(0, 2)
