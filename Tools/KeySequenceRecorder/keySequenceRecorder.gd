class_name keySequenceRecoder extends Node2D

@export var enable: bool = true
@export var input_actions_to_react : Array[String]

## Seconds until the sequence is timed out
@export var sequence_timeout : float = 1


var sequence : Array[String] = []


func _input(event):
	if not enable:
		return
	for action in input_actions_to_react:
		if event.is_action_pressed(action):
			if sequence.size() == 0:
				sequence = [action]
			else:
				sequence.append(action)

func is_inputing_sequence():
	return not sequence.is_empty()

func clear():
	sequence = []

func get_sequence():
	return " ".join(sequence)
