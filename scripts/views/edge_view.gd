extends Control
class_name EdgeView


# Setters for to and from node ids. When changed, connect signals to get updates
@export var from_id := -1 :
	set (new_from_id):
		from_id = new_from_id
		if Controller.get_current_config().get_graph().get_node(from_id) != null:
			Controller.get_current_config().get_graph().get_node(from_id).state_changed.connect(func(): refresh())
	get : return from_id
@export var to_id := -1 :
	set (new_to_id):
		to_id = new_to_id
		if Controller.get_current_config().get_graph().get_node(to_id) != null:
			Controller.get_current_config().get_graph().get_node(to_id).state_changed.connect(func(): refresh())
	get : return to_id


# Cache position of the 'to' node relative to the EdgeViews position on screen
var to_pos := Vector2.ZERO


# Mark if edge is in 'connecting' mode (i.e. creating the edge)
var connecting_mode := false


@onready var arrow : Polygon2D = get_node("Arrow")
@onready var weight_label : LineEdit = get_node("Label")
@onready var weight_label_arrow : Polygon2D = get_node("LabelArrow")
@onready var popup_menu : PopupMenu = get_node("PopupMenu")


# Subscribe to updates from both to and from nodes so that changes are immediately shown
func _ready() -> void:
	Controller.graph_edited.connect(refresh)
	Controller.editor_mode_changed.connect(func(_new_mode): if connecting_mode: queue_free())
	refresh()
	update_right_click_menu()


# Draw the line representing the edge
func _draw() -> void:
	draw_line(Vector2.ZERO, to_pos-(to_pos.normalized()*8), Color.BLACK, 2.0, true)


# Refresh the state of the view
func refresh() -> void:
	var edge : GraphEdgeData = Controller.get_current_config().get_graph().get_edge(from_id, to_id)
	if not connecting_mode and edge == null:
		queue_free()
		return
	if Controller.get_current_config().get_graph().get_node(from_id) != null:
		position = Controller.get_current_config().get_graph().get_node(from_id).position
	# If in connect mode, follow the mouse, otherwise go to end node
	if connecting_mode:
		to_pos = get_local_mouse_position() #- position
	elif to_pos != null and Controller.get_current_config().get_graph().get_node(to_id):
		to_pos = Controller.get_current_config().get_graph().get_node(to_id).position - position
	else:
		to_pos = Vector2.ZERO
	queue_redraw()
	# Move the direction arrow into place
	arrow.position = to_pos - ((to_pos.normalized()*Controller.NODE_RADIUS) if not connecting_mode else Vector2.ZERO)
	arrow.look_at(arrow.global_position+to_pos)
	# If enabled, configure and show the edge's weight
	if Controller.get_current_config().get_option("enable_edge_weights") and edge != null:
		weight_label.text = str(edge.weight)
		var offset := (to_pos.normalized().rotated(-PI/2)*20)
		weight_label.set_position((-weight_label.get_rect().size/2)+(to_pos/2) + offset)
		weight_label_arrow.rotation = arrow.rotation
		weight_label_arrow.position = (to_pos/2) + (offset)
		# Disable editing the weight if weights should be uniform
		if Controller.get_current_config().get_option("force_uniform_path_cost"):
			weight_label.editable = false
			weight_label.text = "1"
		else:
			weight_label.editable = true
		weight_label.show()
		weight_label_arrow.show()
	else:
		weight_label.hide()
		weight_label_arrow.hide()


# Handle input for setting up edge
func _unhandled_input(event: InputEvent) -> void:
	# Refresh view so that edge follows the mouse
	if event is InputEventMouseMotion and connecting_mode:
		refresh()
	
	if event is InputEventMouseButton and weight_label.has_focus():
		weight_label.call_deferred("release_focus")

	# When you click on another node, exit connecting mode and create the edge
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and connecting_mode:
		for node in get_parent().get_children():
			if node is NodeView and (event.position - (node.global_position)).length() < Controller.NODE_RADIUS and node.node_id != from_id:
				to_id = node.node_id
				if Controller.get_current_config().get_graph().get_edge(from_id, to_id) != null:
					queue_free()
					return
				Controller.get_current_config().get_graph().add_edge(from_id, to_id)
				connecting_mode = false
				# refresh()
				Controller.register_graph_change()
				get_viewport().set_input_as_handled()
				break
	
	# If right clicking on (or close to) the edge, open the context menu
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed() and not connecting_mode:
		var p := get_global_mouse_position() - global_position
		var proj := p.dot(to_pos)
		var ablen_sqr := to_pos.length_squared()
		var d := proj / ablen_sqr
		var cp : Vector2
		if d <= 0:
			cp = Vector2.ZERO
		elif d >= 1:
			cp = to_pos
		else:
			cp = to_pos * d
		if (cp-p).length_squared() < 25.0 :
			popup_menu.popup_on_parent(get_global_rect())
			popup_menu.position += Vector2i(get_local_mouse_position().floor())
			get_viewport().set_input_as_handled()


# Setup the right click popup menu
func update_right_click_menu() -> void:
	popup_menu.clear()
	# Check if edge in other direction also exists
	var opposite := Controller.get_current_config().get_graph().get_edge(to_id, from_id)
	if opposite == null:
		popup_menu.add_item("Delete edge", 0)
	else:
		# Provide options for deleting either (since you can only actually select one due to handling)
		var from_label := Controller.get_current_config().get_graph().get_node(from_id).label
		var to_label := Controller.get_current_config().get_graph().get_node(to_id).label
		popup_menu.add_separator("From " + from_label + " to " + to_label)
		popup_menu.add_item("Delete edge", 0)
		popup_menu.add_separator("From " + to_label + " to " + from_label)
		popup_menu.add_item("Delete edge", 1)


# When the user tries to edit the weight, check the text is valid (i.e. numbers)
func _on_label_text_changed(new_text: String) -> void:
	for i in range(len(new_text)):
		if not new_text[i].is_valid_int():
			weight_label.text = new_text.substr(0, i)
			break


# When the user submits a new weight, check its valid then assign it to the actual edge
func _on_label_text_submitted(new_text: String) -> void:
	if new_text.is_valid_int():
		var new_weight := int(new_text)
		var edge : GraphEdgeData = Controller.get_current_config().get_graph().get_edge(from_id, to_id)
		if edge != null:
			edge.weight = new_weight
			refresh()
	weight_label.call_deferred("release_focus")


# Handle clicking an item in the right-click popup menu
func _on_popup_menu_id_pressed(id: int) -> void:
	match id:
		(0):
			# Delete edge with from=from_id and to=to_id
			Controller.get_current_config().get_graph().delete_edge(from_id, to_id)
			Controller.register_graph_change()
		(1):
			# Delete edge with from=to_id and to=from_id
			Controller.get_current_config().get_graph().delete_edge(to_id, from_id)
			Controller.register_graph_change()


func _on_label_focus_exited() -> void:
	_on_label_text_submitted(weight_label.text)
