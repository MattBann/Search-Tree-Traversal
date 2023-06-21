extends VBoxContainer


# Helper function to add a new option as a child
func add_option(option : Dictionary) -> Option:
	var op := Option.create_option()
	add_child(op)
	op.setup_option(option)
	return op


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refresh()


# Clear options and rebuild based on context
func refresh() -> void:
	for child in get_children():
		child.queue_free()
	
	for op in Controller.get_current_config().data:
		add_option(op)

