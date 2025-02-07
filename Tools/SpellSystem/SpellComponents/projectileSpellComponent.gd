class_name ProjectileSpellComponent extends SpellComponent

signal collided

@export var base_speed: float = 100
@export var speed_change: float = 0
@export var min_speed: float = 50
@export var max_speed: float = 200
@export var react_to_non_target_collisions: bool = false
@export var timeout: float = 5
@export var homing_strength: float = 0

@export var projectile_packed_scene: PackedScene
@export var tail_packed_scene: PackedScene

var _projectile: Node2D
var _activation_area: Area2D
var _spell_caster: SpellCaster
var _target: Node2D

var _timeout_timer: Timer

func activate(spell_caster: SpellCaster):
	_spell_caster = spell_caster
	_target = spell_caster.target
	# Setup timeout timer
	_timeout_timer = Timer.new()
	_timeout_timer.one_shot = true
	spell_caster.parent.add_child(_timeout_timer)
	_timeout_timer.timeout.connect(projectilehit)
	_timeout_timer.start(timeout)
	# Setup projectile
	_projectile = projectile_packed_scene.instantiate() as Projectile
	_projectile.base_speed = base_speed
	_projectile.speed_change = speed_change
	_projectile.min_speed = min_speed
	_projectile.max_speed = max_speed
	_projectile.target = _target
	_projectile.homing_strength = homing_strength

	spell_caster.parent.get_parent().add_child(_projectile)
	if _target != null:
		_projectile.direction = spell_caster.global_position.direction_to(_target.global_position)
	else:
		_projectile.direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	_projectile.global_position = spell_caster.global_position

	# Add activationarea
	if _projectile.has_node("ActivationArea"):
		_activation_area = _projectile.get_node("ActivationArea")
	else:
		_activation_area = Area2D.new()
		_projectile.add_child(_activation_area)
		var sprite = _projectile.get_node("Sprite2D")
		var collider = CollisionShape2D.new()
		_activation_area.add_child(collider)
		collider.shape = CircleShape2D.new()
		# Scale activationarea
		collider.shape.radius = max(sprite.texture.get_size().x/2, sprite.texture.get_size().y/2)
	if tail_packed_scene != null:
		var tail = tail_packed_scene.instantiate()as Node2D
		_projectile.add_child(tail)
		_activation_area.body_entered.connect(_on_body_entered)

	await collided
	projectilehit()

func projectilehit():
	if _projectile != null:
		_projectile.queue_free()

func _on_body_entered(body):
	if react_to_non_target_collisions:
		_spell_caster.target = body
		collided.emit()
	elif body == _target:
		collided.emit()
