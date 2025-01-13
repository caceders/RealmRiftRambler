class_name SequenceDecoder extends Node2D

@export var keycodes = {
}

func decode_keycode(keycode: String):
	if keycode in keycodes:
		return keycodes[keycode]
	else:
		return null