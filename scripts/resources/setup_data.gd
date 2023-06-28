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
		}
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


func _init() -> void:
	graph = GraphData.new(data.get("graph", {}))


func get_graph() -> GraphData:
	return graph
