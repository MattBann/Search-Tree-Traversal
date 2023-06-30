class_name SetupData
extends Resource


enum Algorithm {
	BREADTH_FIRST_SEARCH,
	DEPTH_FIRST_SEARCH,
	UNIFORM_COST_SEARCH,
	A_STAR_SEARCH,
}

enum OptionType {
	OPTION_LIST,
	COLOUR_PICK,
	SWITCH,
	TEXT,
	SPIN,
	LABEL
}


@export var graph : GraphData


# The setup data as a list of dictionaries
@export var data := {
	options = [
		{
			name = "algorithm",
			option_type = OptionType.OPTION_LIST,
			value_type = Algorithm,
			value = Algorithm.BREADTH_FIRST_SEARCH,
		},
		{
			name = "start_colour",
			option_type = OptionType.COLOUR_PICK,
			value_type = TYPE_COLOR,
			value = Color.GREEN,
		},
		{
			name = "goal_colour",
			option_type = OptionType.COLOUR_PICK,
			value_type = TYPE_COLOR,
			value = Color.ORANGE,
		},
		{
			name = "node_colour",
			option_type = OptionType.COLOUR_PICK,
			value_type = TYPE_COLOR,
			value = Color.LIGHT_SKY_BLUE,
		},
		{
			name = "fill_nodes",
			option_type = OptionType.SWITCH,
			value_type = TYPE_BOOL,
			value = true,
		},
		{
			name = "enable_edge_weights",
			option_type = OptionType.SWITCH,
			value_type = TYPE_BOOL,
			value = false,
		},
		{
			name = "show_heuristics",
			option_type = OptionType.SWITCH,
			value_type = TYPE_BOOL,
			value = false,
		},
		{
			name = "distance_scale",
			option_type = OptionType.SPIN,
			value_type = {
				min = 1,
				max = 100,
				step = 1
			},
			value = 10,
		},
		{
			name = "force_uniform_path_cost",
			option_type = OptionType.SWITCH,
			value_type = TYPE_BOOL,
			value = true,
		},
	],
	graph = {
		nodes = [],
		edges = [],
		next_id = 0,
	}
}


# Safe way to get option value
func get_option(name : String) -> Variant:
	for i in data.get("options", []):
		if i.get("name", "") == name:
			return i.get("value", null)
	return null


func _init(new_data : Dictionary = {}) -> void:
	if new_data != {}:
			data = new_data
			for i in data.get("options", []):
				if i.get("option_type") == OptionType.COLOUR_PICK and typeof(i.get("value")) == TYPE_STRING:
					i["value"] = colour_string_to_color(i.get("value", "0, 0, 0, 1"))
	graph = GraphData.new(data.get("graph", {}))


func get_graph() -> GraphData:
	return graph


# Helper functions for loading a save
func colour_string_to_color(colour : String) -> Color:
	colour = colour.replace("(", "")
	colour = colour.replace(")", "")
	colour = colour.replace(",", "")
	var c := colour.split(" ")
	var new_colour = Color(float(c[0]), float(c[1]), float(c[2]), float(c[3]))
	return new_colour


func coord_string_to_vector2(coords : String) -> Vector2:
	coords = coords.replace("(", "")
	coords = coords.replace(")", "")
	coords = coords.replace(",", "")
	var x = coords.left(coords.find(" "))
	var y = coords.right(coords.find(" "))
	var new_coords = Vector2(int(x),int(y))
	return new_coords
	