extends Node

@onready var dropper = $ItemDropper as ItemDropper

func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		dropper.drop()

