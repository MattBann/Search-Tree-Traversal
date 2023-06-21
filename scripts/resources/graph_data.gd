class_name GraphData
extends Resource

@export var nodes : Array
@export var next_id : int


# Initialise the graph with no nodes
func _init() -> void:
	nodes = []
	next_id = 0


# Add a node with a unique id to the graph
func add_node() -> GraphNodeData:
	var new_node = GraphNodeData.new(next_id)
	next_id += 1
	nodes.append(new_node)
	return new_node


# Get a node with a specific id
func get_node(id : int) -> GraphNodeData:
	if id < 0:
		return null
	return nodes[id]


# Get the single start node in the graph if it exists, else null
func get_start_node() -> GraphNodeData:
	for node in nodes:
		if node.is_start:
			return node
	return null


# Returns the goal node if there is a single goal node, or null if none/multiple
func get_goal_node() -> GraphNodeData:
	var goal : GraphNodeData = null
	for node in nodes:
		if node.is_goal:
			if goal == null:
				goal = node
			else:
				return null
	return goal


# Force refresh the state of the graph nodes
func refresh_nodes() -> void:
	for node in nodes:
		node.refresh()