extends Panel


var node_packed_scene := preload("res://scenes/node_view.tscn")
var edge_packed_scene := preload("res://scenes/edge_view.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Test data for edges:
	# Controller.get_current_config().get_graph().add_node().position = Vector2(100,100)
	# Controller.get_current_config().get_graph().add_node().position = Vector2(500,300)
	# Controller.get_current_config().get_graph().add_edge(0,1)
	Controller.graph_edited.connect(refresh)
	Controller.clear.connect(reset)
	reset()


func reset() -> void:
	for child in get_children():
		child.queue_free()
	# Add any pre-existent nodes as children
	for node in Controller.get_current_config().get_graph().nodes:
		var node_view := node_packed_scene.instantiate()
		node_view.node_id = node.id
		add_child(node_view)
	# Add any pre-existent edges
	for edge in Controller.get_current_config().get_graph().edges:
		var edge_view := edge_packed_scene.instantiate()
		edge_view.from_id = edge.from
		edge_view.to_id = edge.to
		add_child(edge_view)
	# Controller.register_graph_change()


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
		# If in connect mode, start creating an edge
		elif Controller.get_editor_mode() == Controller.EditorMode.CONNECT:
			for edge in get_children():
				if edge is EdgeView and edge.connecting_mode:
					if (event.position - (edge.position)).length() < Controller.NODE_RADIUS:
						edge.queue_free()
					return
			for node in get_children():
				if node is NodeView and (event.position - (node.position)).length() < Controller.NODE_RADIUS:
					var edge := edge_packed_scene.instantiate()
					edge.connecting_mode = true
					edge.from_id = node.node_id
					add_child(edge)
					break


# Refresh the view (i.e. update the visuals, not the data)
func refresh() -> void:
	for child in get_children():
		if child.has_method("refresh"):
			child.refresh()
		if child.has_method("update_right_click_menu"):
			child.update_right_click_menu()
