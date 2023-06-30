extends MarginContainer
class_name Option


# Variable definitions (with setters and getters)
@export var option_type : SetupData.OptionType : 
	set (new_value): option_type = _set_option_type(new_value)
	get : return option_type
@export var option_name : String :
	set (new_value):
		option_name = new_value
		if label != null:
			label.text = new_value
			label.tooltip_text = new_value
	get: return option_name
@export var option : Dictionary


# References to nodes
@onready var label : Label = get_node("HBoxContainer/Label")
@onready var option_list : OptionButton = get_node("HBoxContainer/OptionList")
@onready var colour_pick : ColorPickerButton = get_node("HBoxContainer/ColorPicker")
@onready var switch : CheckButton = get_node("HBoxContainer/Switch")
@onready var text : TextEdit = get_node("HBoxContainer/Text")
@onready var spin_box : SpinBox = get_node("HBoxContainer/SpinBox")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_all()


# Setup the context of the option view by passing in an option dict
func setup_option(new_option : Dictionary) -> void:
	option = new_option
	option_name = new_option.get("name", "Name").capitalize()
	option_type = new_option.get("option_type", SetupData.OptionType.LABEL)


# Private method for reflecting a change to the option type
func _set_option_type(new_type : SetupData.OptionType) -> SetupData.OptionType:
	hide_all()
	match (new_type):
		(SetupData.OptionType.OPTION_LIST):
			option_list.show()
			if option.get("value_type") is Dictionary:
				set_list_options(option.get("value_type", {}))
				option_list.select(option_list.get_item_index(option.get("value", 0)))
				
		(SetupData.OptionType.COLOUR_PICK):
			colour_pick.show()
			colour_pick.color = option.get("value", Color.BLACK)
		(SetupData.OptionType.SWITCH):
			switch.show()
			switch.set_pressed_no_signal(option.get("value", false))
		(SetupData.OptionType.TEXT):
			text.show()
			text.text = option.get("value", "")
		(SetupData.OptionType.SPIN):
			spin_box.show()
			spin_box.value = option.get("value", 100)
			spin_box.min_value = option.get("value_type", {}).get("min", 0)
			spin_box.max_value = option.get("value_type", {}).get("max", 100)
			spin_box.step = option.get("value_type", {}).get("step", 1)
	return new_type


# Scene contains a node of each option type, use this to hide them all
func hide_all() -> void:
	option_list.hide()
	colour_pick.hide()
	switch.hide()
	text.hide()
	spin_box.hide()


# Set the array of options for the OPTION_LIST
func set_list_options(new_options : Dictionary) -> void:
	option_list.clear()
	for op in new_options:
		option_list.add_item(op.capitalize(), new_options[op])
	# for i in range(len(new_options)):
	# 	if new_options[i] is String:
	# 		option_list.add_item(new_options[i].capitalize(), i)
	# 	else:
	# 		option_list.add_item("", i)


# Signal functions to set a new value for the option:

func _on_option_list_item_selected(_index: int) -> void:
	option["value"] = option_list.get_selected_id()
	Controller.register_graph_change()


func _on_color_picker_color_changed(color: Color) -> void:
	option["value"] = color
	Controller.register_graph_change()


func _on_switch_toggled(button_pressed: bool) -> void:
	option["value"] = button_pressed
	Controller.register_graph_change()


func _on_text_text_changed() -> void:
	option["value"] = text.text
	Controller.register_graph_change()


func _on_spin_box_value_changed(value: float) -> void:
	option["value"] = value
	Controller.register_graph_change()
