class_name Targeter extends Area2D

const UPDATE_TIME_MS = 200

const LINE_LERP_WEIGHT = .1

@export var distance = 100:
	set(value):
		if value < 0: distance = 0
		else: distance = value

@export var highlighter: Color

@export var distance_penalty_line_sort: float = 0.005

## To what degree are the prioritized groups selected over non prioritized

@export var lock_on_display_sprite_packed_scene: PackedScene

@export var priority_group_reards: Dictionary = {"Hostile" : 10, "Creature" : 5}

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
		# Remve highlight
		if _target != null:
			if _target.has_node("Sprite2D"):
				var sprite = _target.get_node("Sprite2D") as Sprite2D
				if sprite != null:
					sprite.modulate = Color(sprite.modulate.r - highlighter.r, sprite.modulate.g - highlighter.g, sprite.modulate.b - highlighter.b)
		_target = value
		if _lock_on_display_sprite != null:
			_lock_on_display_sprite.queue_free()
		_lock_on = false

		# Add highlight
		if _target != null:
			if _target.has_node("Sprite2D"):
				var sprite = _target.get_node("Sprite2D") as Sprite2D
				if sprite != null:
					sprite.modulate = Color(sprite.modulate.r + highlighter.r, sprite.modulate.g + highlighter.g, sprite.modulate.b + highlighter.b)

					
var last_update_time : float = Time.get_ticks_msec()

func _ready():
	body_exited.connect(on_body_exited)

func _process(_delta):
	# Update shaepe
	if $CollisionShape2D.shape.radius != distance:
		var shape = CircleShape2D.new()
		shape.radius = distance
		$CollisionShape2D.shape = shape
	if not Engine.is_editor_hint():
		_line = _line.lerp(target_line, LINE_LERP_WEIGHT)
		if not _lock_on:
			if last_update_time < Time.get_ticks_msec()	 + UPDATE_TIME_MS:
				last_update_time = Time.get_ticks_msec()
				select_target_on_line_with_regards_to_priority()

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

func select_target_on_line_with_regards_to_priority():
	var all_bodies = get_overlapping_bodies()

	var best_target = null
	var best_score = -999999999
	
	for targetable in all_bodies:

		if targetable == get_parent():
			continue
		if not targetable.is_in_group("Targetable"):
			continue
		
		# Find target close to line, not too far away and with regards to priority
		var dir_to_targetable = global_position.direction_to(targetable.global_position)
		var dist_to_targetable = global_position.distance_squared_to(targetable.global_position)
		var dir_difference_targtable = abs(_line - dir_to_targetable)
		var distance_penalty = abs(distance_penalty_line_sort * dist_to_targetable)

		var priority_reward = 0
		for priority_group in priority_group_reards.keys():
			if targetable.is_in_group(priority_group) and priority_reward < priority_group_reards[priority_group]:
				priority_reward = priority_group_reards[priority_group]

		var score =  priority_reward - dir_difference_targtable.length() - distance_penalty

		if best_score < score:
			best_target = targetable
			best_score = score

	if target != best_target:
		target = best_target
	

func on_body_exited(body):
	if body == _target:
		target = null
