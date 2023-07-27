extends Node
class_name Runner


# The sequential, repeating steps the algorithm steps through
enum Stages {
    SELECT_NODE,
    EXPAND_OUT,
    TEST_END_CASE,
    ENQUEUE,
}


var current_stage : Stages


# The current state of the algorithm
var queue : Array[VisualisationNodeData]
var expansion_list : Array[VisualisationNodeData]
var current_node : VisualisationNodeData


# Initialise the Runner by appending the start node to the queue. If the start node does not exist, tells Controller to abort
func _init() -> void:
    var start := Controller.get_current_config().get_graph().get_start_node()
    if not start:
        Controller.abort_visualisation()
        return
    queue.append(VisualisationNodeData.new(start.id, 0))
    current_stage = Stages.SELECT_NODE


# Execute the next stage of the algorithm from the steps in Stages
func step() -> void:
    pass
