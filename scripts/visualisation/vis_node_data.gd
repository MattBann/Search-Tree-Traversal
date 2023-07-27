extends Node
class_name VisualisationNodeData


# Store reference to the node it represents and the specific distance from the start node for this entry
var node_id : int = -1
var distance : int = 0


func _init(new_node_id : int, new_distance : int) -> void:
    node_id = new_node_id
    distance = new_distance