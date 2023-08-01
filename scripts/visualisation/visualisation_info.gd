extends VBoxContainer
class_name VisualisationInfo


@onready var algorithm_type_label : Label = get_node("AlgorithmTypeLabel")
@onready var current_node_label : Label = get_node("PanelContainer/MarginContainer/CurrentNodeLabel")
@onready var expansion_list_label : Label = get_node("PanelContainer2/MarginContainer/ExpansionListLabel")
@onready var goal_test_label : Label = get_node("GoalTestLabel")
@onready var queue_label : Label = get_node("PanelContainer3/MarginContainer/QueueLabel")


# Connect listeners to signals from the Runner
func _ready() -> void:
	var runner := Controller.get_current_runner()
	if runner == null:
		queue_free()
		return
	runner.current_node_changed.connect(_on_current_node_changed)
	runner.expansion_list_changed.connect(_on_expansion_list_changed)
	runner.goal_test_failed.connect(_on_goal_test_fail)
	runner.found_path.connect(_on_path_found)
	runner.queue_changed.connect(_on_queue_changed)
	var algorithm : SetupData.Algorithm = Controller.get_current_config().get_option("algorithm")
	algorithm_type_label.text = "Algorithm: " + (SetupData.Algorithm.find_key(algorithm) as String).capitalize()


# Update text showing the current node and its path cost
func _on_current_node_changed(current_node : VisualisationNodeData) -> void:
	current_node_label.text = Controller.get_current_config().get_graph().get_node(current_node.node_id).label + " (" + str(current_node.cost) + ")"


# Update text showing the list of nodes reachable from the current node
func _on_expansion_list_changed(new_list : Array[VisualisationNodeData]) -> void:
	goal_test_label.text = ""
	expansion_list_label.text = ""
	for i in range(len(new_list)):
		expansion_list_label.text += Controller.get_current_config().get_graph().get_node(new_list[i].node_id).label + " (" + str(new_list[i].cost) + ")"
		if i != len(new_list) - 1: expansion_list_label.text += "\n"


# Update text to say that the current node is not a goal node
func _on_goal_test_fail() -> void:
	goal_test_label.text = Controller.get_current_config().get_graph().get_node(Controller.get_current_runner().current_node.node_id).label + " is not the goal state"


# Update text to say that the current node is a goal node
func _on_path_found(_path) -> void:
	goal_test_label.text = Controller.get_current_config().get_graph().get_node(Controller.get_current_runner().current_node.node_id).label + "is the goal state, so a path has been found!"


# Update text showing the queue of nodes waiting to become current node
func _on_queue_changed(new_queue : Array[VisualisationNodeData]) -> void:
	queue_label.text = ""
	for i in range(len(new_queue)):
		queue_label.text += Controller.get_current_config().get_graph().get_node(new_queue[i].node_id).label + " (" + str(new_queue[i].cost) + ")"
		if i != len(new_queue) - 1: queue_label.text += "\n"