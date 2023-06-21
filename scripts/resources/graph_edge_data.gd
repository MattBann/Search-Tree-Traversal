class_name GraphEdgeData
extends Resource


@export var from : int
@export var to : int
@export var weight : float


# Initialise the edge
func _init(from_id : int, to_id : int, new_weight : float) -> void:
	from = from_id
	to = to_id
	weight = new_weight
