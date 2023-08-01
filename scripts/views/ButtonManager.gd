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
@onready var runner_auto_step : Button = get_node("RunnerAutoButton")
@onready var auto_run_timer : Timer = get_node("Timer")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Controller.graph_edited.connect(graph_edited)
	Controller.editor_mode_changed.connect(_on_editor_mode_change)
	file_menu.get_popup().id_pressed.connect(on_file_menu_item_pressed)
	if OS.get_name() == "Web":
		file_menu.get_popup().remove_item(1)
	auto_run_timer.timeout.connect(func (): \
		Controller.get_current_runner().step() if Controller.is_visualisation_running() \
		else auto_run_timer.stop())


# Handle toggling of editor mode, including deselecting other modes:
func _on_editor_mode_change(new_mode : Controller.EditorMode) -> void:
	if new_mode != Controller.EditorMode.MOVE:
		move.set_pressed_no_signal(false)
	if new_mode != Controller.EditorMode.CONNECT:
		connect.set_pressed_no_signal(false)
	if new_mode != Controller.EditorMode.PLACE_START:
		start.set_pressed_no_signal(false)
	if new_mode != Controller.EditorMode.PLACE_GOAL:
		goal.set_pressed_no_signal(false)
	if new_mode != Controller.EditorMode.PLACE_NODE:
		node.set_pressed_no_signal(false)
	if new_mode == Controller.EditorMode.VISUALISER_RUNNING:
		for child in get_children():
			if child.is_in_group("editor_controls"):
				child.hide()
			elif child.is_in_group("runner_controls"):
				child.show()
	else:
		for child in get_children():
			if child.is_in_group("editor_controls"):
				child.show()
			elif child.is_in_group("runner_controls"):
				child.hide()


func _on_place_node_button_toggled(button_pressed:bool) -> void:
	if button_pressed:
		Controller.set_editor_mode(Controller.EditorMode.PLACE_NODE)
	else:
		Controller.set_editor_mode(Controller.EditorMode.FREE)


func _on_place_goal_button_toggled(button_pressed:bool) -> void:
	if button_pressed:
		Controller.set_editor_mode(Controller.EditorMode.PLACE_GOAL)
	else:
		Controller.set_editor_mode(Controller.EditorMode.FREE)


func _on_place_start_button_toggled(button_pressed:bool) -> void:
	if button_pressed:
		Controller.set_editor_mode(Controller.EditorMode.PLACE_START)
	else:
		Controller.set_editor_mode(Controller.EditorMode.FREE)


func _on_connect_button_toggled(button_pressed:bool) -> void:
	if button_pressed:
		Controller.set_editor_mode(Controller.EditorMode.CONNECT)
	else:
		Controller.set_editor_mode(Controller.EditorMode.FREE)


func _on_move_button_toggled(button_pressed:bool) -> void:
	if button_pressed:
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
	

# When visualisation start button pressed, tell Controller to start runner
func _on_start_vis_button_pressed() -> void:
	Controller.start_visualisation()
	runner_auto_step.button_pressed = false


# Step through the visualisation
func _on_runner_step_button_pressed() -> void:
	if Controller.is_visualisation_running():
		Controller.get_current_runner().step()
	else:
		Controller.abort_visualisation()
	

# Stop the visualisation
func _on_runner_stop_button_pressed() -> void:
	Controller.abort_visualisation()


# Start a timer to automatically step through the visualisation
func _on_runner_auto_button_toggled(button_pressed:bool) -> void:
	if button_pressed:
		auto_run_timer.wait_time = 1.0 # TODO Setup step interval control
		auto_run_timer.one_shot = false
		auto_run_timer.start()
	else:
		auto_run_timer.stop()


# Button icon attribution: https://www.flaticon.com/authors/freepik