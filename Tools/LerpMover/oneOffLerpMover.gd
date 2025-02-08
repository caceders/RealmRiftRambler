class_name OneOffLerpMover extends Node

const CLOSE_ENOUGH = .2

@export var target_position: Vector2
@export var lerp_weight: float = 0.1

@onready var parent: Node2D = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if parent.global_position.distance_to(target_position) < CLOSE_ENOUGH:
		queue_free()
	parent.global_position = parent.global_position.lerp(target_position, lerp_weight)
