extends Control


@export var vis_info_packed_scene := preload("res://scenes/visualisation_info.tscn")


@onready var setup_manager := get_node("SetupManager")


var vis_info : VisualisationInfo


func _ready():
	Controller.editor_mode_changed.connect(_on_editor_mode_changed)


# If visualisation starts, replace the setup manager with information from the algorithm, else make sure setup manager is shown
func _on_editor_mode_changed(new_mode : Controller.EditorMode) -> void:
	if new_mode == Controller.EditorMode.VISUALISER_RUNNING:
		setup_manager.hide()
		if vis_info != null: vis_info.queue_free()
		vis_info = vis_info_packed_scene.instantiate()
		add_child(vis_info)
	else:
		if vis_info != null: vis_info.queue_free()
		setup_manager.show()
