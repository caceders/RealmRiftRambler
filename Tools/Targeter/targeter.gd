@tool
class_name Targeter extends Area2D
@export var distance = 100:
	set(value):
		if value < 0: distance = 0
		else: distance = value
@export var highlighter: Color

var _targetable: Array[Node2D] = []

var _target: Node2D

var _nearest: Node2D

var _lock_on: bool = false

var target: Node2D:
	get:
		return _target
	set(value):
		if _target != null:
			if _target.has_node("Sprite2D"):
				var sprite = _target.get_node("Sprite2D") as Sprite2D
				if sprite != null:
					sprite.modulate = Color(sprite.modulate.r - highlighter.r, sprite.modulate.g - highlighter.g, sprite.modulate.b - highlighter.b)
					
		_target = value
		if _target != null:
			if _target.has_node("Sprite2D"):
				var sprite = _target.get_node("Sprite2D") as Sprite2D
				if sprite != null:
					sprite.modulate = Color(sprite.modulate.r + highlighter.r, sprite.modulate.g + highlighter.g, sprite.modulate.b + highlighter.b)
					


func _ready():
	body_exited.connect(on_body_exited)

func _physics_process(_delta):
	_targetable = get_overlapping_bodies()
	if get_parent() in _targetable:
		_targetable.erase(get_parent())
	if not _targetable.is_empty():
		_targetable.sort_custom(sort_distance)
		if (_nearest != _targetable[0] and not _lock_on) or target == null:
			_nearest = _targetable[0]
			target = _targetable[0]
	if $CollisionShape2D.shape.radius != distance:
		var shape = CircleShape2D.new()
		shape.radius = distance
		$CollisionShape2D.shape = shape
	return

func start_lock_on():
	_lock_on = true

func end_lock_on():
	_lock_on = false

func select_next_target():
	if not _targetable.is_empty():
		var current_target_index = _targetable.find(target)
		current_target_index = current_target_index + 1
		if current_target_index == _targetable.size():
			current_target_index = 0
		target = _targetable[current_target_index]

func sort_distance(a, b):
	return (global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))

func on_body_exited(body):
	if body == _target:
		target = null
