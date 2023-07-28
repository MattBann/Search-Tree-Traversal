extends HBoxContainer


# References to scene nodes
@onready var move : Button = get_node("MoveButton")
@onready var connect : Button = get_node("ConnectButton")
@onready var start : Button = get_node("PlaceStartButton")
@onready var goal : Button = get_node("PlaceGoalButton")
@onready var node : Button = get_node("PlaceNodeButton")
@onready var file_menu : MenuButton = get_node("FileMenuButton")
@onready var file_save_dialog : FileDialog = get_node("FileDialogSave")
@onready var file_open_dialog : FileDialog = get_node("FileDialogOpen")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Controller.graph_edited.connect(graph_edited)
	file_menu.get_popup().id_pressed.connect(on_file_menu_item_pressed)
	if OS.get_name() == "Web":
		file_menu.get_popup().remove_item(1)


# Handle toggling of editor mode, including deselecting other modes:

func _on_place_node_button_toggled(button_pressed:bool) -> void:
	if button_pressed:
		move.set_pressed_no_signal(false)
		connect.set_pressed_no_signal(false)
		start.set_pressed_no_signal(false)
		goal.set_pressed_no_signal(false)
		Controller.set_editor_mode(Controller.EditorMode.PLACE_NODE)
	else:
		Controller.set_editor_mode(Controller.EditorMode.FREE)


func _on_place_goal_button_toggled(button_pressed:bool) -> void:
	if button_pressed:
		move.set_pressed_no_signal(false)
		connect.set_pressed_no_signal(false)
		start.set_pressed_no_signal(false)
		node.set_pressed_no_signal(false)
		Controller.set_editor_mode(Controller.EditorMode.PLACE_GOAL)
	else:
		Controller.set_editor_mode(Controller.EditorMode.FREE)


func _on_place_start_button_toggled(button_pressed:bool) -> void:
	if button_pressed:
		move.set_pressed_no_signal(false)
		connect.set_pressed_no_signal(false)
		goal.set_pressed_no_signal(false)
		node.set_pressed_no_signal(false)
		Controller.set_editor_mode(Controller.EditorMode.PLACE_START)
	else:
		Controller.set_editor_mode(Controller.EditorMode.FREE)


func _on_connect_button_toggled(button_pressed:bool) -> void:
	if button_pressed:
		move.set_pressed_no_signal(false)
		start.set_pressed_no_signal(false)
		goal.set_pressed_no_signal(false)
		node.set_pressed_no_signal(false)
		Controller.set_editor_mode(Controller.EditorMode.CONNECT)
	else:
		Controller.set_editor_mode(Controller.EditorMode.FREE)


func _on_move_button_toggled(button_pressed:bool) -> void:
	if button_pressed:
		connect.set_pressed_no_signal(false)
		start.set_pressed_no_signal(false)
		goal.set_pressed_no_signal(false)
		node.set_pressed_no_signal(false)
		Controller.set_editor_mode(Controller.EditorMode.MOVE)
	else:
		Controller.set_editor_mode(Controller.EditorMode.FREE)


# When the graph is edited, check if a start node was placed and if so deselect/disable the place start button
func graph_edited() -> void:
	if Controller.get_current_config().get_graph().get_start_node() != null:
		if start.button_pressed:
			start.set_pressed_no_signal(false)
			Controller.set_editor_mode(Controller.EditorMode.FREE)
		start.disabled = true
	else:
		start.disabled = false


# When the user clicks from one of Save, Save as, Open or New
func on_file_menu_item_pressed(id : int) -> void:
	match id:
		(0):
			# save
			# If platform is web, download the file:
			if OS.get_name() == "Web":
				Controller.web_save()
				return
			# If currently editing a state that hasn't been saved before, do save as, otherwise resave
			if Controller.current_file == "":
				save_as()
			else:
				Controller.save_state(Controller.current_file)
		(1):
			# save as
			save_as()
		(2):
			# open
			# If platform is web, ask for file upload:
			if OS.get_name() == "Web":
				Controller.web_load()
				return
			# Open an open file dialog and prevent input to the program
			file_open_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
			file_open_dialog.popup_centered()
			get_node("/root/UI").mouse_filter = Control.MOUSE_FILTER_STOP
		(3):
			# new
			Controller.start_new()


# Open a save file dialog and prevent input to the program
func save_as() -> void:
	file_save_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	file_save_dialog.popup_centered()
	get_node("/root/UI").mouse_filter = Control.MOUSE_FILTER_STOP


# When user selects a file to open, tell controller to open it
func _on_file_dialog_open_file_selected(path:String):
	Controller.load_state_from_file(path)


# When user selects a file to write to, tell controller to save to it
func _on_file_dialog_save_file_selected(path:String):
	Controller.save_state(path)


# When dialog closes, make sure to resume input to the program
func _on_file_dialog_visibility_changed() -> void:
	if get_node("/root/UI").mouse_filter == Control.MOUSE_FILTER_STOP:
		get_node("/root/UI").mouse_filter = Control.MOUSE_FILTER_PASS
	
