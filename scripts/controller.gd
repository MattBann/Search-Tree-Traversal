extends Node


# Global signals so that nodes know when things have changed
signal editor_mode_changed(new_mode:EditorMode)
signal graph_edited
signal new_state_loaded
signal clear


enum EditorMode{
	MOVE,
	CONNECT,
	PLACE_START,
	PLACE_GOAL,
	PLACE_NODE,
	FREE
}


const NODE_RADIUS := 32


# Global data which is accessible through getters and setters
var _current_config : SetupData
var _editor_mode : EditorMode = EditorMode.FREE


var current_file := ""


func _init() -> void:
	_current_config = SetupData.new()


# Getter for _current_config
func get_current_config() -> SetupData:
	return _current_config


func get_editor_mode() -> EditorMode:
	return _editor_mode


func set_editor_mode(new_mode : EditorMode) -> void:
	_editor_mode = new_mode
	editor_mode_changed.emit(new_mode)


func register_graph_change() -> void:
	_current_config.graph.refresh_nodes()
	graph_edited.emit()


# Save the current config to the given file
func save_state(path : String) -> void:
	var save := FileAccess.open(path, FileAccess.WRITE)
	if save == null:
		push_error("Error while trying to write to '{0}'".format([path]))
		return
	var json_string := JSON.stringify(_current_config.data, "\t")
	save.store_pascal_string(json_string)
	save.close()


# Load a config from the given file
func load_state_from_file(path : String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	# Check file open operation succeeded
	if file == null:
		push_error("Error while trying to read from '{0}'".format([path]))
		return
	# Attempt to parse file contents as JSON
	var json_string := file.get_pascal_string()
	var json := JSON.new()
	var result := json.parse(json_string)
	if result != OK:
		push_error("JSON Parse Error: ",  json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		file.close()
		return
	var data = json.data
	# Check that file contents match expected type
	if typeof(data) != TYPE_DICTIONARY:
		push_error("File contents do not match expected type: Expected Dictionary, got ", str(typeof(data)))
		file.close()
		return
	_current_config = SetupData.new(data)
	current_file = path
	file.close()
	clear.emit()
	new_state_loaded.emit()
	register_graph_change()


# Reset the state of the program and close the currently open file
func start_new() -> void:
	# TODO Add check for if file currently open and has unsaved changes
	current_file = ""
	_current_config = SetupData.new()
	clear.emit()
	new_state_loaded.emit()
	register_graph_change()
