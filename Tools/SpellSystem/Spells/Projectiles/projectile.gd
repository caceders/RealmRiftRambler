class_name Projectile extends Node2D

@export var base_speed: float = 100
@export var speed_change: float = 0
@export var min_speed: float = 50
@export var max_speed: float = 200
@export var target: Node2D
@export var homing_strength: float = .1
@export var direction: Vector2:
	get:
		return _direction
	set(value):
		_direction = value

var _speed = base_speed
var _direction: Vector2

func _ready():
	if target != null:
		_direction = global_position.direction_to(target.global_position)
	else:
		_direction = Vector2(randf_range(-1,1), randf_range(1,1)).normalized()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target != null and homing_strength != 0:
		_direction = _direction.lerp(global_position.direction_to(target.position), homing_strength)

	global_position += _direction * _speed * delta
	_speed += speed_change * delta
	if _speed < min_speed:
		_speed = min_speed
	elif _speed > max_speed:
		_speed = max_speed
