extends Control
class_name EdgeView


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


var to_pos := Vector2.ZERO
var connecting := false


@onready var arrow : Polygon2D = get_node("Arrow")


# Subscribe to updates from both to and from nodes so that changes are immediately shown
func _ready() -> void:
	Controller.graph_edited.connect(refresh)
	Controller.editor_mode_changed.connect(queue_free)
	refresh()


# Draw the line representing the edge
func _draw() -> void:
	draw_line(Vector2.ZERO, to_pos-(to_pos.normalized()*8), Color.BLACK, 2.0, true)


# Refresh the state of the view
func refresh() -> void:
	position = Controller.get_current_config().get_graph().get_node(from_id).position
	# If in connect mode, follow the mouse, otherwise go to end node
	if connecting:
		to_pos = get_local_mouse_position() #- position
	elif to_pos != null:
		to_pos = Controller.get_current_config().get_graph().get_node(to_id).position - position
	else:
		to_pos = Vector2.ZERO
	queue_redraw()
	# Move the direction arrow into place
	arrow.position = to_pos - ((to_pos.normalized()*Controller.NODE_RADIUS) if not connecting else Vector2.ZERO)
	arrow.look_at(arrow.global_position+to_pos)


# Handle input for setting up edge
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and connecting:
		refresh()
	if event is InputEventMouseButton and event.is_pressed() and connecting:
		for node in get_parent().get_children():
			if node is NodeView and (event.position - (node.global_position)).length() < Controller.NODE_RADIUS and node.node_id != from_id:
				to_id = node.node_id
				Controller.get_current_config().get_graph().add_edge(from_id, to_id)
				connecting = false
				refresh()
				break
