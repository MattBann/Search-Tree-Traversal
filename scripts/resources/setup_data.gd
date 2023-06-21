class_name SetupData
extends Resource


enum Algorithm {
	BFS,
	DFS,
	UCS,
	ASTAR,
}

enum OptionType {
	OPTION_LIST,
	COLOUR_PICK,
	SWITCH,
	TEXT,
	LABEL
}


@export var graph : GraphData


# The setup data as a list of dictionaries
@export var data := [
	{
		name = "algorithm",
		option_type = OptionType.OPTION_LIST,
		value_type = Algorithm,
		value = Algorithm.BFS,
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
	}
]


# Safe way to get option value
func get_option(name : String) -> Variant:
	for i in data:
		if i.get("name", "") == name:
			return i.get("value", null)
	return null


func _init() -> void:
	graph = GraphData.new()


func get_graph() -> GraphData:
	return graph



