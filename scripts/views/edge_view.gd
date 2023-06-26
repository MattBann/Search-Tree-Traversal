extends Control


@export var from_id : int
@export var to_id : int


var to_pos := Vector2.ZERO


@onready var arrow : Polygon2D = get_node("Arrow")


# Subscribe to updates from both to and from nodes so that changes are immediately shown
func _ready() -> void:
	Controller.graph_edited.connect(refresh)
	Controller.get_current_config().get_graph().get_node(to_id).state_changed.connect(refresh)
	Controller.get_current_config().get_graph().get_node(from_id).state_changed.connect(refresh)
	refresh()


# Draw the line representing the edge
func _draw() -> void:
	draw_line(Vector2.ZERO, to_pos, Color.BLACK, 2.0, true)


# Refresh the state of the view
func refresh() -> void:
	position = Controller.get_current_config().get_graph().get_node(from_id).position
	to_pos = Controller.get_current_config().get_graph().get_node(to_id).position - position
	queue_redraw()
	# Move the direction arrow into place
	arrow.position = to_pos - to_pos.normalized()*Controller.NODE_RADIUS
	arrow.look_at(arrow.global_position+to_pos)