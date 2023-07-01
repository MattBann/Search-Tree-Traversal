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


# Subscribe to updates from both to and from nodes so that changes are immediately shown
func _ready() -> void:
	Controller.graph_edited.connect(refresh)
	Controller.editor_mode_changed.connect(func(_new_mode): if connecting_mode: queue_free())
	refresh()


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
		weight_label.set_position((-weight_label.get_rect().size/2)+(to_pos/2)+(to_pos.normalized().rotated(-PI/2)*20))
		# Disable editing the weight if weights should be uniform
		if Controller.get_current_config().get_option("force_uniform_path_cost"):
			weight_label.editable = false
			weight_label.text = "1"
		else:
			weight_label.editable = true
		weight_label.show()
	else:
		weight_label.hide()


# Handle input for setting up edge
func _unhandled_input(event: InputEvent) -> void:
	# Refresh view so that edge follows the mouse
	if event is InputEventMouseMotion and connecting_mode:
		refresh()
	# When you click on another node, exit connecting mode and create the edge
	if event is InputEventMouseButton and event.is_pressed() and connecting_mode:
		for node in get_parent().get_children():
			if node is NodeView and (event.position - (node.global_position)).length() < Controller.NODE_RADIUS and node.node_id != from_id:
				to_id = node.node_id
				if Controller.get_current_config().get_graph().get_edge(from_id, to_id) != null:
					queue_free()
					return
				Controller.get_current_config().get_graph().add_edge(from_id, to_id)
				connecting_mode = false
				refresh()
				break


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
