class_name Bobber extends Node
const CLOSE_ENOUGH: float = .2


@export var amplitude: float = 1
@export var lerp_weight: float = .05

@onready var parent: Node2D = get_parent()
@onready var sprite: Sprite2D = parent.get_node("Sprite2D")
@onready var start_position = sprite.offset
var direction = "up"

func _ready():
	sprite.offset += Vector2(0, randf_range(-amplitude, amplitude)) # Start at a random bobbing position

func _process(delta):
	if direction == "up":
		sprite.offset = sprite.offset.lerp(Vector2(start_position.x, start_position.y + amplitude), lerp_weight)
		if sprite.offset.y - start_position.y > ( + amplitude - CLOSE_ENOUGH):
			direction = "down"

	elif direction == "down":
		sprite.offset = sprite.offset.lerp(Vector2(start_position.x, start_position.y - amplitude), lerp_weight)
		if sprite.offset.y - start_position.y < (- amplitude + CLOSE_ENOUGH):
			direction = "up"