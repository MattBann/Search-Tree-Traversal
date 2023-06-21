extends HBoxContainer


# References to scene nodes
@onready var move : Button = get_node("MoveButton")
@onready var connect : Button = get_node("ConnectButton")
@onready var start : Button = get_node("PlaceStartButton")
@onready var goal : Button = get_node("PlaceGoalButton")
@onready var node : Button = get_node("PlaceNodeButton")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Controller.graph_edited.connect(graph_edited)


# Handle toggling of editor mode, including deselecting other modes:

func _on_place_node_button_toggled(button_pressed:bool) -> void:
	if button_pressed:
		move.set_pressed_no_signal(false)
		connect.set_pressed_no_signal(false)
		start.set_pressed_no_signal(false)
		goal.set_pressed_no_signal(false)
		Controller.set_editor_mode(Controller.EditorMode.PLACE_NODE)
	else:
		Controller.set_editor_mode(Controller.EditorMode.FREE)


func _on_place_goal_button_toggled(button_pressed:bool) -> void:
	if button_pressed:
		move.set_pressed_no_signal(false)
		connect.set_pressed_no_signal(false)
		start.set_pressed_no_signal(false)
		node.set_pressed_no_signal(false)
		Controller.set_editor_mode(Controller.EditorMode.PLACE_GOAL)
	else:
		Controller.set_editor_mode(Controller.EditorMode.FREE)


func _on_place_start_button_toggled(button_pressed:bool) -> void:
	if button_pressed:
		move.set_pressed_no_signal(false)
		connect.set_pressed_no_signal(false)
		goal.set_pressed_no_signal(false)
		node.set_pressed_no_signal(false)
		Controller.set_editor_mode(Controller.EditorMode.PLACE_START)
	else:
		Controller.set_editor_mode(Controller.EditorMode.FREE)


func _on_connect_button_toggled(button_pressed:bool) -> void:
	if button_pressed:
		move.set_pressed_no_signal(false)
		start.set_pressed_no_signal(false)
		goal.set_pressed_no_signal(false)
		node.set_pressed_no_signal(false)
		Controller.set_editor_mode(Controller.EditorMode.CONNECT)
	else:
		Controller.set_editor_mode(Controller.EditorMode.FREE)


func _on_move_button_toggled(button_pressed:bool) -> void:
	if button_pressed:
		connect.set_pressed_no_signal(false)
		start.set_pressed_no_signal(false)
		goal.set_pressed_no_signal(false)
		node.set_pressed_no_signal(false)
		Controller.set_editor_mode(Controller.EditorMode.MOVE)
	else:
		Controller.set_editor_mode(Controller.EditorMode.FREE)


# When the graph is edited, check if a start node was placed and if so deselect/disable the place start button
func graph_edited() -> void:
	if Controller.get_current_config().get_graph().get_start_node() != null:
		if start.button_pressed:
			start.set_pressed_no_signal(false)
			Controller.set_editor_mode(Controller.EditorMode.FREE)
		start.disabled = true
	else:
		start.disabled = false