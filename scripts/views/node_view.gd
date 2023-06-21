extends Control


@export var RADIUS := 32


@export var node_id := -1
var colour : Color
var dragging := false
var drag_offset := Vector2.ZERO


@onready var label : Label = get_node("Label")
@onready var heuristic_label : Label = get_node("Heuristic")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refresh()


# Draw the circle representing the node
func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, colour)
	if not Controller.get_current_config().get_option("fill_nodes"):
		draw_circle(Vector2.ZERO, RADIUS-4, Color.WHITE)


# Update the visual representation of the node based on the currently configured options
func refresh() -> void:
	var node := Controller.get_current_config().get_graph().get_node(node_id)

	# Handle case of no assigned node:
	if node == null:
		colour = Controller.get_current_config().get_option("node_colour")
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
	heuristic_label.set_position((-heuristic_label.get_rect().size/2)+Vector2(0,RADIUS+heuristic_label.get_rect().size.y/2))
	if Controller.get_current_config().get_option("show_heuristics"):
		heuristic_label.show()
	else: 
		heuristic_label.hide()
	queue_redraw()


# Process input that hasn't aready been intercepted
func _unhandled_input(event : InputEvent):
	# If the user clicks the node in move mode, start dragging it
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and Controller.get_editor_mode() == Controller.EditorMode.MOVE:
		if (event.position - global_position).length() < RADIUS:
			if not dragging and event.is_pressed():
				dragging = true
				drag_offset = event.position - global_position
				get_parent().move_child(self, -1)
				get_viewport().set_input_as_handled()
		if dragging and not event.is_pressed():
			dragging = false
			set_settled_position()
	
	# If dragging, follow the mouse (until the limits of the panel)
	if event is InputEventMouseMotion and dragging:
		var parent := get_parent()
		global_position = (event.position - drag_offset).clamp(parent.global_position, parent.global_position+parent.size)


# Update the node data to reflect the new position
func set_settled_position() -> void:
	var node := Controller.get_current_config().get_graph().get_node(node_id)
	if node == null:
		return
	node.position = position
