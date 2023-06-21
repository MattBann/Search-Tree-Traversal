extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# var graph := GraphData.new()
	# var node := graph.add_node()
	# var node2 := graph.add_node()
	# node.add_edge(node2.id)
	# node2.add_edge(node.id)
	
	# var result := ResourceSaver.save(graph, "user://test_graph.tres")
	# print(result)
	# assert(result == OK)
	print(Controller.get_current_config().data[0]["name"])
