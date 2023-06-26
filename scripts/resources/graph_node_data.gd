class_name GraphNodeData
extends Resource


signal state_changed


# Use setter for position so that heuristic also gets updated
@export var position : Vector2 :
	set (new_pos):
		position = new_pos
		var goal := Controller.get_current_config().get_graph().get_goal_node()
		if goal != null:
			var scale : int = Controller.get_current_config().get_option("distance_scale")
			if scale != null:
				heuristic_value = floor(((goal.position - new_pos)*(scale/100.0)).length())
		else:
			heuristic_value = 0
	get: return position

# Other variables
@export var label : String
@export var id : int
@export var edges : Array
@export var is_start : bool
@export var is_goal : bool
@export var heuristic_value : int


# Initialise the graph node
func _init(p_id : int, pos := Vector2.ZERO, p_label := "", p_is_start := false, p_is_goal := false) -> void:
	position = pos
	id = p_id
	if p_label == "":
		label = str(id)
	else:
		label = p_label
	edges = []
	is_start = p_is_start
	is_goal = p_is_goal


# Add an edge to a specific node with an optional weight
func add_edge(end_id : int, weight := 1.0) -> void:
	var new_edge := GraphEdgeData.new(self.id, end_id, weight)
	edges.append(new_edge)


# Force the position setter to update the heuristic
func refresh() -> void:
	position = position
