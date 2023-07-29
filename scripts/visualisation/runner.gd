extends Node
class_name Runner


signal current_node_changed(new_current_node:VisualisationNodeData)
signal expansion_list_changed(new_expansion_list:Array[VisualisationNodeData])
signal found_path(goal_data:VisualisationNodeData)
signal queue_changed(new_queue:Array[VisualisationNodeData])


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


# Initialise the Runner by appending the start node to the queue. If the start node does not exist, tells Controller to abort
func _init() -> void:
    var start := Controller.get_current_config().get_graph().get_start_node()
    if not start:
        Controller.abort_visualisation()
        return
    queue.append(VisualisationNodeData.new(start.id, 0, null))
    current_stage = Stages.SELECT_NODE


# Execute the next stage of the algorithm from the steps in Stages
func step() -> void:
    match (current_stage):
        (Stages.SELECT_NODE):
            # Pop a node from the front of the queue
            current_node = queue.pop_front()
            if current_node == null:
                Controller.abort_visualisation()
                return
            expansion_list.clear()
            current_node_changed.emit(current_node)
        
        (Stages.TEST_END_CASE):
            # Check if reached a goal state
            for goal_node in Controller.get_current_config().get_graph().get_goal_nodes():
                if current_node.node_id == goal_node.id:
                    completed_path = true
                    found_path.emit(current_node)
                    if OS.is_debug_build():
                        print("Found Path:")
                        var s := ""
                        s += str(current_node.node_id) + " <- "
                        var n := current_node.previous_node
                        while n:
                            s += str(n.node_id) + " <- "
                            n = n.previous_node
                        print(s)
                    return
        
        (Stages.EXPAND_OUT):
            # Expand outwards from the current node, ignoring visited nodes
            for edge in Controller.get_current_config().get_graph().get_edges_from(current_node.node_id):
                if not edge.to in visited:
                    print(edge.weight)
                    expansion_list.append(VisualisationNodeData.new(edge.to, current_node.cost + (1.0 if Controller.get_current_config().get_option("force_uniform_path_cost") else edge.weight), current_node))
            expansion_list_changed.emit(expansion_list)
        
        (Stages.ENQUEUE):
            # Add the expanded nodes to the queue, using the chosen search type's enqueueing algorithm and mark node as visited
            enqueue()
            visited.append(current_node.node_id)

    # Output state in console for debugging
    if OS.is_debug_build():
        print("Stage: ", Stages.find_key(current_stage))
        print("Current node: ", current_node)
        print("Expansion: ", expansion_list)
        print("Queue: ", queue)
        print("Visisted: ", visited)
        print("")

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
    queue_changed.emit(queue)
