class_name GraphEdgeData
extends Resource


@export var from : int :
	set (new_from): data["from"] = new_from
	get: return data.get("from", -1)
@export var to : int :
	set (new_to): data["to"] = new_to
	get: return data.get("to", -1)
@export var weight : float :
	set (new_weight): data["weight"] = new_weight
	get: return data.get("weight", 1)


# The actual data. Properties above provide easy access to this dictionary
@export var data := {
	from = -1,
	to = -1,
	weight = 1,
}



# Initialise the edge
func _init(from_id := -1, to_id := -1, new_weight := -1.0) -> void:
	from = from_id
	to = to_id
	weight = new_weight
