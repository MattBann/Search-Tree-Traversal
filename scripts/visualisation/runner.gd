extends Node
class_name Runner


signal current_node_changed(new_current_node:VisualisationNodeData)
signal expansion_list_changed(new_expansion_list:Array[VisualisationNodeData])
signal found_path(goal_data:VisualisationNodeData)
signal goal_test_failed
signal queue_changed(new_queue:Array[VisualisationNodeData])
signal runner_stepped(new_stage:Stages)


# The sequential, repeating steps the algorithm steps through
enum Stages {
	SELECT_NODE,
	TEST_END_CASE,
	EXPAND_OUT,
	ENQUEUE,
}


var current_stage : Stages


# The current state of the algorithm
var queue : Array[VisualisationNodeData] = []
var expansion_list : Array[VisualisationNodeData] = []
var visited : Array[int] = []
var current_node : VisualisationNodeData
var completed_path : bool = false
var algorithm_variables : Dictionary = {}


# Initialise the Runner by appending the start node to the queue. If the start node does not exist, tells Controller to abort
func _init() -> void:
	var start := Controller.get_current_config().get_graph().get_start_node()
	if start == null:
		Controller.abort_visualisation()
		return
	queue.append(VisualisationNodeData.new(start.id, 0, null))
	current_stage = Stages.SELECT_NODE
	# Setup special variables certain algorithms
	if Controller.get_current_config().get_option("algorithm") == SetupData.Algorithm.ITERATIVE_DEEPENING_DEPTH_FIRST_SEARCH:
		# Set max_depth var
		algorithm_variables["max_depth"] = 0
		# Set current_depth var
		algorithm_variables["current_depth"] = -1
		algorithm_variables["depth_stack"] = [0]


static func get_path_to_node(node : VisualisationNodeData) -> String:
	var nodes := PackedStringArray()
	var n := node
	while n:
		nodes.append(Controller.get_current_config().get_graph().get_node(n.node_id).label)
		n = n.previous_node
	nodes.reverse()
	var path := " -> ".join(nodes)
	return path


func is_edge_in_path(from_id : int, to_id : int) -> bool:
	var n := current_node
	while n and n.previous_node:
		if n.node_id == to_id and n.previous_node.node_id == from_id:
			return true
		else:
			n = n.previous_node
	return false


# Execute the next stage of the algorithm from the steps in Stages
func step() -> void:
	if completed_path:
		Controller.abort_visualisation()
		return
	runner_stepped.emit(current_stage)
	match (current_stage):
		(Stages.SELECT_NODE):
			# Pop a node from the front of the queue. If node is visited, try again
			while true:
				current_node = queue.pop_front()
				if current_node == null:
					Controller.abort_visualisation()
					return
				if current_node.node_id not in visited:
					break
			expansion_list.clear()
			# If current_depth is defined, update its value
			if algorithm_variables.has("current_depth"):
				algorithm_variables["current_depth"] = (algorithm_variables.get("depth_stack", []) as Array).pop_front()
			current_node_changed.emit(current_node)
			queue_changed.emit(queue)
		
		(Stages.TEST_END_CASE):
			# Check if reached a goal state
			for goal_node in Controller.get_current_config().get_graph().get_goal_nodes():
				if current_node.node_id == goal_node.id:
					completed_path = true
					found_path.emit(current_node)
					if OS.is_debug_build():
						print("Found Path:")
						print(Runner.get_path_to_node(current_node))
						print("With path length " + str(current_node.cost))
					Controller.register_graph_change()
					return
			goal_test_failed.emit()
		
		(Stages.EXPAND_OUT):
			# Expand outwards from the current node, ignoring visited nodes
			# Special case: IDDFS: if at depth limit don't expand
			if algorithm_variables.get("current_depth", -1) != algorithm_variables.get("max_depth", 0):
				for edge in Controller.get_current_config().get_graph().get_edges_from(current_node.node_id):
					if not edge.to in visited:
						print(edge.weight)
						expansion_list.append(VisualisationNodeData.new(edge.to, current_node.cost + (1.0 if Controller.get_current_config().get_option("force_uniform_path_cost") else edge.weight), current_node))
				expansion_list_changed.emit(expansion_list)
		
		(Stages.ENQUEUE):
			# Add the expanded nodes to the queue, using the chosen search type's enqueueing algorithm and mark node as visited
			visited.append(current_node.node_id)
			enqueue()
			expansion_list.clear()
			expansion_list_changed.emit(expansion_list)

	# Output state in console for debugging
	if OS.is_debug_build():
		print("Stage: ", Stages.find_key(current_stage))
		print("Current node: ", current_node)
		print("Expansion: ", expansion_list)
		print("Queue: ", queue)
		print("Visisted: ", visited)
		print("Algorithm variables: ", algorithm_variables)
		print("")

	# Tell Controller that something has changed
	Controller.register_graph_change()

	# Move to next stage:
	current_stage = ((current_stage+1) % Stages.size()) as Stages


func enqueue() -> void:
	# Use a different enqueueing algorithm for each search type
	var algorithm : SetupData.Algorithm = Controller.get_current_config().get_option("algorithm")
	match (algorithm):
		(SetupData.Algorithm.BREADTH_FIRST_SEARCH):
			# Enqueue at end, regardless of path cost
			queue.append_array(expansion_list)
		
		(SetupData.Algorithm.UNIFORM_COST_SEARCH):
			# Enqueue by cost (i.e. add to q then sort by cost)
			queue.append_array(expansion_list)
			queue.sort_custom(func (a:VisualisationNodeData,b:VisualisationNodeData): return a.cost < b.cost)
		
		(SetupData.Algorithm.DEPTH_FIRST_SEARCH):
			# Enqueue at start, regardless of path cost
			for i in expansion_list:
				queue.push_front(i)
		
		(SetupData.Algorithm.A_STAR_SEARCH):
			# Enqueue by cost+heuristic (i.e. add to q then sort)
			queue.append_array(expansion_list)
			queue.sort_custom(func (a:VisualisationNodeData,b:VisualisationNodeData): 
				return a.cost + Controller.get_current_config().get_graph().get_node(a.node_id).heuristic_value < b.cost + Controller.get_current_config().get_graph().get_node(b.node_id).heuristic_value)
		
		(SetupData.Algorithm.ITERATIVE_DEEPENING_DEPTH_FIRST_SEARCH):
			# Enqueue at start, unless at the max depth for this iteration, in which case start over with max_depth+1
			# (Expansion list should aready be empty if at max depth)
			for i in expansion_list:
				queue.push_front(i)
				algorithm_variables.get("depth_stack", []).push_front(algorithm_variables.get("current_depth", 0)+1)
			# If queue is empty, then reset depth first search with an increased max_depth
			if queue.is_empty():
				visited.clear()
				queue.append(VisualisationNodeData.new(Controller.get_current_config().get_graph().get_start_node().id, 0, null))
				algorithm_variables.get("depth_stack", []).push_front(0)
				algorithm_variables["max_depth"] = algorithm_variables.get("max_depth", 0) + 1
				algorithm_variables["current_depth"] += 1
			
	queue_changed.emit(queue)
