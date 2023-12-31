extends Node
class_name VisualisationNodeData


# Store reference to the node it represents and the specific distance from the start node for this entry
var node_id : int = -1
var cost : float = 0.0
var previous_node : VisualisationNodeData


func _init(new_node_id : int, new_cost : float, prev_node : VisualisationNodeData) -> void:
    node_id = new_node_id
    cost = new_cost
    previous_node = prev_node


func _to_string() -> String:
    var heuristic : String = (" + " + str(Controller.get_current_config().get_graph().get_node(node_id).heuristic_value)) \
        if Controller.get_current_config().get_option("algorithm") == SetupData.Algorithm.A_STAR_SEARCH \
        or Controller.get_current_config().get_option("algorithm") == SetupData.Algorithm.GREEDY_BEST_FIRST_SEARCH \
        else ""
    return "node: " + Controller.get_current_config().get_graph().get_node(node_id).label + " (" + str(node_id) + heuristic + "), cost: " + str(cost)