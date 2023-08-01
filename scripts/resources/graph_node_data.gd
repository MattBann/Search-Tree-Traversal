class_name GraphNodeData
extends Resource


signal state_changed


# Use setter for position so that heuristic also gets updated
@export var position : Vector2 :
	set (new_pos):
		data["position"] = new_pos
		var goal := Controller.get_current_config().get_graph().get_goal_nodes()
		if len(goal) == 1:
			var scale : int = Controller.get_current_config().get_option("distance_scale")
			if scale != null:
				heuristic_value = floor(((goal[0].position - new_pos)*(scale/100.0)).length())
		else:
			heuristic_value = 0
		state_changed.emit()
	get:
		if typeof(data.get("position")) == TYPE_STRING:
			return Vector2(coord_string_to_vector2(data.get("position")))
		return data.get("position", Vector2.ZERO)

# Other variables
@export var label : String :
	set (new_label):
		data["label"] = new_label
	get: return data.get("label", "")
@export var id : int :
	set (new_id): data["id"] = new_id
	get: return data.get("id", -1)
@export var is_start : bool :
	set (new_is_start): data["is_start"] = new_is_start
	get: return data.get("is_start", false)
@export var is_goal : bool :
	set (new_is_goal): data["is_goal"] = new_is_goal
	get: return data.get("is_goal", false)
@export var heuristic_value : int :
	set (new_heuristic_value): data["heuristic_value"] = new_heuristic_value
	get: return data.get("heuristic_value", 0)


# The actual data. Properties above provide easy access to this dictionary
@export var data := {
	"position" : Vector2.ZERO,
	"label" : "",
	"id" : -1,
	"is_start" : false,
	"is_goal" : false,
	"heuristic_value" : false
}


# Initialise the graph node
func _init(p_id := -1, pos := Vector2.ZERO, p_label := "", p_is_start := false, p_is_goal := false) -> void:
	position = pos
	id = p_id
	if p_label == "":
		label = str(id)
	else:
		label = p_label
	is_start = p_is_start
	is_goal = p_is_goal


# Force the position setter to update the heuristic
func refresh() -> void:
	position = position


# Convert a string in the form "(x, y)" into a vector2 object
func coord_string_to_vector2(coords : String) -> Vector2:
	coords = coords.replace("(", "")
	coords = coords.replace(")", "")
	coords = coords.replace(",", "")
	var x = coords.left(coords.find(" "))
	var y = coords.right(-1*coords.find(" "))
	var new_coords = Vector2(int(x),int(y))
	return new_coords
