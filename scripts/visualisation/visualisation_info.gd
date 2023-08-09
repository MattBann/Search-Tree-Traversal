extends VBoxContainer
class_name VisualisationInfo


@onready var algorithm_type_label : Label = get_node("AlgorithmTypeLabel")
@onready var current_stage_label : Label = get_node("CurrentStageLabel")
@onready var current_node_label : Label = get_node("PanelContainer/MarginContainer/CurrentNodeLabel")
@onready var expansion_list_label : Label = get_node("PanelContainer2/MarginContainer/ExpansionListLabel")
@onready var goal_test_label : Label = get_node("GoalTestLabel")
@onready var queue_label : Label = get_node("PanelContainer3/MarginContainer/QueueLabel")
@onready var extras_label : Label = get_node("ExtrasLabel")


# Connect listeners to signals from the Runner
func _ready() -> void:
	var runner := Controller.get_current_runner()
	if runner == null:
		queue_free()
		return
	runner.runner_stepped.connect(_on_runner_stepped)
	runner.current_node_changed.connect(_on_current_node_changed)
	runner.expansion_list_changed.connect(_on_expansion_list_changed)
	runner.goal_test_failed.connect(_on_goal_test_fail)
	runner.found_path.connect(_on_path_found)
	runner.queue_changed.connect(_on_queue_changed)
	var algorithm : SetupData.Algorithm = Controller.get_current_config().get_option("algorithm")
	algorithm_type_label.text = "Algorithm: " + (SetupData.Algorithm.find_key(algorithm) as String).capitalize()
	if Controller.get_current_runner().algorithm_variables.has("max_depth"):
		extras_label.show()
		extras_label.text = "Max depth: " + str(Controller.get_current_runner().algorithm_variables.get("max_depth", 0))
	else:
		extras_label.hide()
	_on_runner_stepped()


func _on_runner_stepped(new_stage : Runner.Stages = Runner.Stages.SELECT_NODE) -> void:
	current_stage_label.text = "Current step: " + Runner.Stages.find_key(new_stage).capitalize()


func _get_node_text(node : VisualisationNodeData) -> String:
	var heuristic : String = (" + " + str(Controller.get_current_config().get_graph().get_node(node.node_id).heuristic_value)) if Controller.get_current_config().get_option("algorithm") == SetupData.Algorithm.A_STAR_SEARCH else ""
	return Controller.get_current_config().get_graph().get_node(node.node_id).label + " (" + str(node.cost) + heuristic + ")"


# Update text showing the current node and its path cost
func _on_current_node_changed(current_node : VisualisationNodeData) -> void:
	current_node_label.text = _get_node_text(current_node)
	if Controller.get_current_runner().algorithm_variables.has("max_depth"):
		extras_label.show()
		extras_label.text = "Max depth: " + str(Controller.get_current_runner().algorithm_variables.get("max_depth", 0))


# Update text showing the list of nodes reachable from the current node
func _on_expansion_list_changed(new_list : Array[VisualisationNodeData]) -> void:
	goal_test_label.text = ""
	expansion_list_label.text = ""
	for i in range(len(new_list)):
		expansion_list_label.text += _get_node_text(new_list[i])
		if i != len(new_list) - 1: expansion_list_label.text += "\n"


# Update text to say that the current node is not a goal node
func _on_goal_test_fail() -> void:
	goal_test_label.text = Controller.get_current_config().get_graph().get_node(Controller.get_current_runner().current_node.node_id).label + " is not the goal state"


# Update text to say that the current node is a goal node
func _on_path_found(goal_node) -> void:
	goal_test_label.text = Controller.get_current_config().get_graph().get_node(Controller.get_current_runner().current_node.node_id).label \
		+ " is the goal state, so a path has been found!\nThe path is:\n" \
		+ Runner.get_path_to_node(goal_node) + "\nWith a cost of " + str(goal_node.cost)


# Update text showing the queue of nodes waiting to become current node
func _on_queue_changed(new_queue : Array[VisualisationNodeData]) -> void:
	queue_label.text = ""
	for i in range(len(new_queue)):
		queue_label.text += _get_node_text(new_queue[i])
		if i != len(new_queue) - 1: queue_label.text += "\n"
