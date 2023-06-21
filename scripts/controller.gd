extends Node


# Global signals so that nodes know when things have changed
signal editor_mode_changed(new_mode:EditorMode)
signal graph_edited


enum EditorMode{
	MOVE,
	CONNECT,
	PLACE_START,
	PLACE_GOAL,
	PLACE_NODE,
	FREE
}


# Global data which is accessible through getters and setters
var _current_config : SetupData
var _editor_mode : EditorMode = EditorMode.FREE


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