class_name GraphData
extends Resource
# Interface class for interacting with the graph. The actual graph is stored as a dictionary in SetupData


var graph : Dictionary


# These properties do not actually store data, but provide a fixed method to access the graph dictionary data
var nodes : Array :
	set (new_nodes): graph["nodes"] = new_nodes
	get: return graph.get("nodes", [])
var edges : Array :
	set (new_edges): graph["edges"] = new_edges
	get: return graph.get("edges", [])
var next_id : int :
	set (new_next_id): graph["next_id"] = new_next_id
	get: return graph.get("next_id", 0)


# Internal arrays to store references to GraphNode/EdgeData objects, since the 'nodes/edges' arrays only store dictionaries
var node_cache : Array = []
var edge_cache : Array = []


# Initialise object with reference to the actual graph data
func _init(new_graph : Dictionary) -> void:
	graph = new_graph
	# Create and store the interface objects to allow easy access and manipulation
	for node in nodes:
		while node.get("id", 0) + 1 > node_cache.size():
			node_cache.append(null)
		var new_node_interface := GraphNodeData.new()
		new_node_interface.data = node
		node_cache[node.get("id", 0)] = new_node_interface
	for edge in edges:
		var new_edge_interface := GraphEdgeData.new()
		new_edge_interface.data = edge
		edge_cache.append(new_edge_interface)


# Add a node with a unique id to the graph
func add_node() -> GraphNodeData:
	var new_node = GraphNodeData.new(next_id)
	next_id += 1
	nodes.append(new_node.data)
	node_cache.append(new_node)
	return new_node


# Get a node with a specific id
func get_node(id : int) -> GraphNodeData:
	if id < 0 or node_cache.size() <= id:
		return null
	return node_cache[id]


# Get the single start node in the graph if it exists, else null
func get_start_node() -> GraphNodeData:
	for node in node_cache:
		if node.is_start:
			return node
	return null


# Returns the goal node if there is a single goal node, or null if none/multiple
func get_goal_node() -> GraphNodeData:
	var goal : GraphNodeData = null
	for node in node_cache:
		if node.is_goal:
			if goal == null:
				goal = node
			else:
				return null
	return goal


# Force refresh the state of the graph nodes
func refresh_nodes() -> void:
	for node in node_cache:
		if node != null:
			node.refresh()


# Add an edge to a specific node with an optional weight
func add_edge(to_id : int, end_id : int, weight := 1.0) -> void:
	var new_edge := GraphEdgeData.new(to_id, end_id, weight)
	edges.append(new_edge.data)
	edge_cache.append(new_edge)


# Get a specific edge if it exists, otherwise return null
func get_edge(from_id : int, to_id : int) -> GraphEdgeData:
	for edge in edge_cache:
		if edge.from == from_id and edge.to == to_id:
			return edge
	return null
