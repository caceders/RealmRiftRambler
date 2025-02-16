@tool
class_name Targeter extends Area2D

const UPDATE_TIME_MS = 200

const LINE_LERP_WEIGHT = .1

@export var distance = 100:
	set(value):
		if value < 0: distance = 0
		else: distance = value

@export var highlighter: Color

@export var distance_penalty_line_sort: float = 0.00005

@export var lock_on_display_sprite_packed_scene: PackedScene

var target_line: Vector2 = Vector2.UP

var _line: Vector2 = Vector2.UP

var _lock_on_display_sprite: AnimatedSprite2D = null

var _targetables: Array[Node2D] = []

var _target: Node2D

var _nearest: Node2D


var lock_on: bool = false:
	get:
		return _lock_on
	set(value):
		_lock_on = value

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
		if _lock_on_display_sprite != null:
			_lock_on_display_sprite.queue_free()
		_lock_on = false
		if _target != null:
			if _target.has_node("Sprite2D"):
				var sprite = _target.get_node("Sprite2D") as Sprite2D
				if sprite != null:
					sprite.modulate = Color(sprite.modulate.r + highlighter.r, sprite.modulate.g + highlighter.g, sprite.modulate.b + highlighter.b)
					
var last_update_time : float = Time.get_ticks_msec()

func _ready():
	body_exited.connect(on_body_exited)

func _process(_delta):
	_line = _line.lerp(target_line, LINE_LERP_WEIGHT)
	if not _lock_on:
		if last_update_time < Time.get_ticks_msec()	 + UPDATE_TIME_MS:
			last_update_time = Time.get_ticks_msec()
			select_target_on_line()
	return 

func start_lock_on():
	if target != null:
		lock_on = true
		_lock_on_display_sprite = lock_on_display_sprite_packed_scene.instantiate()
		target.add_child(_lock_on_display_sprite)
		_lock_on_display_sprite.position = Vector2.ZERO

func end_lock_on():
	lock_on = false
	if _lock_on_display_sprite != null:
		_lock_on_display_sprite.queue_free()

func select_target_on_line():
	var all_bodies = get_overlapping_bodies()
	_targetables = []

	for entity in all_bodies:
		if "Targetable" in entity.get_groups():
			_targetables.append(entity)

	# Remove targets outside "Cone" of line "o<"
	var target_outside_cone = []
	for targetable in _targetables:
		var distance_from_center_squared = global_position.distance_squared_to(targetable.global_position)
		var distance_from_line_squared = distance_from_center_squared * sin(global_position.angle_to(targetable.global_position))
		var distance_to_point_on_line_squared = distance_from_center_squared * cos(global_position.angle_to(targetable.global_position))
		if abs(distance_from_line_squared/2) > abs(distance_to_point_on_line_squared):
			target_outside_cone.append(targetable)

	if not target_outside_cone.is_empty():
		for entity in target_outside_cone:
			_targetables.erase(entity)
	
	# Remove owner
	if get_parent() in _targetables:
		_targetables.erase(get_parent())

	
	if not _targetables.is_empty():
		for entity in target_outside_cone:
			_targetables.erase(entity)

		_targetables.sort_custom(sortline)
		if (_nearest != _targetables[0]) or target == null:
			_nearest = _targetables[0]
			target = _targetables[0]
	if $CollisionShape2D.shape.radius != distance:
		var shape = CircleShape2D.new()
		shape.radius = distance
		$CollisionShape2D.shape = shape
	return

func select_closest_target():
	var all_bodies = get_overlapping_bodies()
	_targetables = []
	# Remove non-targetable
	var non_targets = []
	for entity in all_bodies:
		if "Targetable" in entity.get_groups():
			_targetables.append(entity)
	
	# Remove owner
	if get_parent() in _targetables:
		_targetables.erase(get_parent())

	
	if not _targetables.is_empty():
		for entity in non_targets:
			_targetables.erase(entity)
		_targetables.sort_custom(sort_distance)
		if (_nearest != _targetables[0]) or target == null:
			_nearest = _targetables[0]
			target = _targetables[0]
	if $CollisionShape2D.shape.radius != distance:
		var shape = CircleShape2D.new()
		shape.radius = distance
		$CollisionShape2D.shape = shape
	return

func select_next_target():
	if not _targetables.is_empty():
		var current_target_index = _targetables.find(target)
		current_target_index = current_target_index + 1
		if current_target_index == _targetables.size():
			current_target_index = 0
		target = _targetables[current_target_index]

func sort_distance(a, b):
	return (global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))

func sortline(a, b):
	# Find the target closest to the line with respect to the distance to the target
	var dir_to_a = global_position.direction_to(a.global_position)
	var dir_to_b = global_position.direction_to(b.global_position)

	var dist_to_a = global_position.distance_squared_to(a.global_position)
	var dist_to_b = global_position.distance_squared_to(b.global_position)

	var dir_difference_a = abs(_line - dir_to_a)
	var dir_difference_b = abs(_line - dir_to_b)

	var score_a = dir_difference_a.length() + distance_penalty_line_sort * dist_to_a
	var score_b = dir_difference_b.length() + distance_penalty_line_sort * dist_to_b

	return (score_a < score_b)

func on_body_exited(body):
	if body == _target:
		target = null
