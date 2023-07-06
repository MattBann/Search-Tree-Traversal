extends Control
class_name NodeView


@export var node_id := -1
var colour : Color
var dragging := false
var drag_offset := Vector2.ZERO


@onready var label : Label = get_node("Label")
@onready var heuristic_label : Label = get_node("Heuristic")
@onready var popup_menu : PopupMenu = get_node("PopupMenu")
@onready var convert_submenu : PopupMenu = get_node("PopupMenu/ConvertSubmenu")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refresh()
	update_right_click_menu()


# Draw the circle representing the node
func _draw() -> void:
	draw_circle(Vector2.ZERO, Controller.NODE_RADIUS, colour)
	if not Controller.get_current_config().get_option("fill_nodes"):
		draw_circle(Vector2.ZERO, Controller.NODE_RADIUS-4, Color.WHITE)


# Update the visual representation of the node based on the currently configured options
func refresh() -> void:
	var node := Controller.get_current_config().get_graph().get_node(node_id)

	# Handle case of no assigned node:
	if node == null:
		colour = Color.RED
		return

	# Assigned node was found, now set the visuals to match it
	position = node.position
	if node.is_start:
		colour = Controller.get_current_config().get_option("start_colour")
	elif node.is_goal:
		colour = Controller.get_current_config().get_option("goal_colour")
	else:
		colour = Controller.get_current_config().get_option("node_colour")
	label.text = node.label
	label.set_position(-label.get_rect().size/2)
	heuristic_label.text = str(node.heuristic_value)
	heuristic_label.set_position((-heuristic_label.get_rect().size/2)+Vector2(0,Controller.NODE_RADIUS+heuristic_label.get_rect().size.y/2))
	if Controller.get_current_config().get_option("show_heuristics"):
		heuristic_label.show()
	else: 
		heuristic_label.hide()
	queue_redraw()


func update_right_click_menu() -> void:
	# Setup right-click popup menu
	popup_menu.clear()
	popup_menu.add_item("Delete node", 0)
	popup_menu.add_submenu_item("Convert to:", "ConvertSubmenu", 1)
	convert_submenu.clear()
	convert_submenu.add_item("Start node", 0)
	convert_submenu.add_item("Goal node", 1)
	convert_submenu.add_item("Node", 2)
	var node := Controller.get_current_config().get_graph().get_node(node_id)
	if node == null:
		return
	# Disable button if not possible to convert to that type
	if node.is_start or Controller.get_current_config().get_graph().get_start_node() != null:
		convert_submenu.set_item_disabled(0, true)
	if node.is_goal:
		convert_submenu.set_item_disabled(1, true)
	if not (node.is_start or node.is_goal):
		convert_submenu.set_item_disabled(2, true)
	

# Process input that hasn't aready been intercepted
func _unhandled_input(event : InputEvent):
	# If the user clicks the node in move mode, start dragging it
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and Controller.get_editor_mode() == Controller.EditorMode.MOVE:
		if (event.position - global_position).length() < Controller.NODE_RADIUS:
			if not dragging and event.is_pressed():
				dragging = true
				drag_offset = event.position - global_position
				get_parent().move_child(self, -1)
				get_viewport().set_input_as_handled()
		if dragging and not event.is_pressed():
			dragging = false
	
	# If dragging, follow the mouse (until the limits of the panel)
	if event is InputEventMouseMotion and dragging:
		var parent := get_parent()
		global_position = (event.position - drag_offset).clamp(parent.global_position, parent.global_position+parent.size)
		set_node_position()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and (event.position - global_position).length() < Controller.NODE_RADIUS:
		if not dragging and event.is_pressed():
			popup_menu.popup_on_parent(get_global_rect())

# Update the node data to reflect the new position
func set_node_position() -> void:
	var node := Controller.get_current_config().get_graph().get_node(node_id)
	if node == null:
		return
	node.position = position


func _on_popup_menu_id_pressed(id:int):
	match id:
		(0):
			# Delete
			Controller.get_current_config().get_graph().delete_node(node_id)
			Controller.register_graph_change()
			queue_free()


func _on_convert_submenu_id_pressed(id:int):
	print("HELLO")
	match id:
		(0):
			# To start
			if Controller.get_current_config().get_graph().get_start_node() == null:
				Controller.get_current_config().get_graph().get_node(node_id).is_start = true
				Controller.get_current_config().get_graph().get_node(node_id).is_goal = false
		(1):
			# To goal
			Controller.get_current_config().get_graph().get_node(node_id).is_goal = true
			Controller.get_current_config().get_graph().get_node(node_id).is_start = false
		(2):
			# To normal node
			Controller.get_current_config().get_graph().get_node(node_id).is_start = false
			Controller.get_current_config().get_graph().get_node(node_id).is_goal = false
	Controller.register_graph_change()
