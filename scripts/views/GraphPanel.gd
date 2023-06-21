extends Panel


var node_packed_scene := preload("res://scenes/node_view.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Controller.graph_edited.connect(refresh)
	# Add any pre-existent nodes as children
	for node in Controller.get_current_config().get_graph().nodes:
		var node_view := node_packed_scene.instantiate()
		node_view.node_id = node.id
		add_child(node_view)
	Controller.register_graph_change()


# Handle input for adding new nodes
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		# Handle each editor mode seperately
		if Controller.get_editor_mode() == Controller.EditorMode.PLACE_NODE:
			var node := Controller.get_current_config().get_graph().add_node()
			node.position = event.position
			var node_view := node_packed_scene.instantiate()
			node_view.node_id = node.id
			add_child(node_view)
			Controller.register_graph_change()
		elif Controller.get_editor_mode() == Controller.EditorMode.PLACE_GOAL:
			var node := Controller.get_current_config().get_graph().add_node()
			node.position = event.position
			node.is_goal = true
			var node_view := node_packed_scene.instantiate()
			node_view.node_id = node.id
			add_child(node_view)
			Controller.register_graph_change()
		elif Controller.get_editor_mode() == Controller.EditorMode.PLACE_START:
			var node := Controller.get_current_config().get_graph().add_node()
			node.position = event.position
			node.is_start = true
			var node_view := node_packed_scene.instantiate()
			node_view.node_id = node.id
			add_child(node_view)
			Controller.register_graph_change()


# Refresh the view (i.e. update the visuals, not the data)
func refresh() -> void:
	for child in get_children():
		if child.has_method("refresh"):
			child.refresh()