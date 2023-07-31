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
	VISUALISER_RUNNING,
	FREE
}


const NODE_RADIUS := 32


# Global data which is accessible through getters and setters
var _current_config : SetupData
var _editor_mode : EditorMode = EditorMode.FREE
var _pre_vis_editor_mode : EditorMode
var _is_visualisation_running : bool = false
var _current_runner : Runner


var current_file := ""


func _init() -> void:
	_current_config = SetupData.new()
	clear.connect(func () : abort_visualisation())


# Getter for _current_config
func get_current_config() -> SetupData:
	return _current_config


func get_editor_mode() -> EditorMode:
	return _editor_mode


func is_visualisation_running() -> bool:
	return _is_visualisation_running


func set_editor_mode(new_mode : EditorMode) -> void:
	_editor_mode = new_mode
	editor_mode_changed.emit(new_mode)


func register_graph_change() -> void:
	_current_config.graph.refresh_nodes()
	graph_edited.emit()


func get_current_runner() -> Runner:
	return _current_runner


# Create the runner and start the visualisation
func start_visualisation() -> void:
	_is_visualisation_running = true
	_pre_vis_editor_mode = _editor_mode
	_current_runner = Runner.new()
	set_editor_mode(EditorMode.VISUALISER_RUNNING)


# Stop the visualisation
func abort_visualisation() -> void:
	_current_runner = null
	_is_visualisation_running = false
	set_editor_mode(_pre_vis_editor_mode)
	register_graph_change()


# Save the current config to the given file
func save_state(path : String) -> void:
	var save := FileAccess.open(path, FileAccess.WRITE)
	if save == null:
		push_error("Error while trying to write to '{0}'".format([path]))
		return
	var json_string := JSON.stringify(_current_config.data, "\t")
	save.store_string(json_string)
	save.close()


# Load a config from the given file
func load_state_from_file(path : String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	# Check file open operation succeeded
	if file == null:
		push_error("Error while trying to read from '{0}'".format([path]))
		return
	# Attempt to parse file contents as JSON
	# var json_string := file.get_pascal_string()
	var json_string := file.get_as_text(true)
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


func web_save() -> void:
	# Verify that platform is web
	if not OS.get_name() == "Web":
		return
	var json_string := JSON.stringify(_current_config.data, "\t")
	var js_command = "save_file(\'" + json_string.c_escape() + "\')"
	var _ret = JavaScriptBridge.eval(js_command)


func web_load() -> void:
	# Verify that platform is web
	if not OS.get_name() == "Web":
		return
	var _ret # Generic return value
	# Use Javascript global context to make things easier
	_ret = JavaScriptBridge.eval("var fileData = 'init var';", true)
	_ret = JavaScriptBridge.eval("pick_file();", true)
	var _timer = Timer.new()
	_timer.wait_time = 3
	_timer.one_shot = true
	self.add_child(_timer)
	# Give user 30 seconds to choose file. Check if chosen every 3 seconds
	for _a in range(10):
		_timer.start()
		await _timer.timeout
		_ret = JavaScriptBridge.eval("fileData;", true)
		if _ret == "init var":
			# keep on waiting or timeout
			pass
		else:
			# stop timer as no longer needed
			_timer.stop()
			_timer.queue_free()
			var json := JSON.new()
			var result := json.parse(_ret)
			if result != OK:
				push_error("JSON Parse Error: ",  json.get_error_message(), " in ", _ret, " at line ", json.get_error_line())
				return
			var data = json.data
			# Check that file contents match expected type
			if typeof(data) != TYPE_DICTIONARY:
				push_error("File contents do not match expected type: Expected Dictionary, got ", str(typeof(data)))
				return
			_current_config = SetupData.new(data)
			clear.emit()
			new_state_loaded.emit()
			register_graph_change()
			return
	# Show warning after 30 seconds
	JavaScriptBridge.eval("alert('Load timed out, please try again');")
	_timer.queue_free()
			


# Reset the state of the program and close the currently open file
func start_new() -> void:
	# TODO Add check for if file currently open and has unsaved changes
	current_file = ""
	_current_config = SetupData.new()
	clear.emit()
	new_state_loaded.emit()
	register_graph_change()
