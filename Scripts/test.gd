extends Node2D
@export var object_scene: PackedScene  # Drag your scene (e.g., Sprite2D) into this field in the editor
@export var player: Node2D

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:  # Left mouse button
			spawn_object(get_global_mouse_position())

func spawn_object(position: Vector2):
	if object_scene:
		var instance = object_scene.instantiate()  # Instantiate the object
		instance.position = position  # Set the object's position to the mouse position
		add_child(instance)  # Add the object to the scene tree
	else:
		print("Object scene not assigned!")
