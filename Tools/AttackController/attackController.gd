class_name AttackController extends Node2D

signal charge_started
signal charge_end
signal attack_started

enum AttackType{
	NEAREST,
	ALL,
	SPECIFIC,
}

@export var attack_area: AttackArea
@export var damage_dealer: DamageDealer
@export var attack_type: AttackType = AttackType.NEAREST

@export var stun_time: float = .3
@export var attack_cooldown: float = 1
@export var attack_duration: float = .2
@export var attack_charge: float = .2

var _stun_timer : Timer
var _attack_cooldown_timer : Timer
var _attack_duration_timer : Timer
var _attack_charge_timer : Timer

func _ready():

	_stun_timer = Timer.new()
	_stun_timer.one_shot = true
	add_child(_stun_timer)

	_attack_cooldown_timer = Timer.new()
	_attack_cooldown_timer.one_shot = true
	add_child(_attack_cooldown_timer)

	_attack_duration_timer = Timer.new()
	_attack_duration_timer.one_shot = true
	add_child(_attack_duration_timer)

	_attack_charge_timer = Timer.new()
	_attack_charge_timer.one_shot = true
	add_child(_attack_charge_timer)

	_attack_charge_timer.timeout.connect(_attack_charge_timer_timeout)

func charge_attack():
	charge_started.emit()
	_attack_charge_timer.start(attack_charge)

func reset_charge():
	_attack_charge_timer.start(0)

func is_charge_finished():
	return _attack_charge_timer.time_left == 0

func attack(amount: float, knockback: bool, body = null):
	attack_started.emit()
	if can_attack():
		if attack_type == AttackType.NEAREST:
			attack_area.attack_nearest_body_in_group(amount, knockback, damage_dealer)
		elif attack_type == AttackType.ALL:
			attack_area.attack_all_bodies_in_group(amount, knockback, damage_dealer)
		elif attack_type == AttackType.SPECIFIC:
			if body:
				attack_area.attack_body(amount, knockback, damage_dealer, body)
		_attack_cooldown_timer.start(attack_cooldown)
		_attack_duration_timer.start(attack_duration)

var _attack_canceled = false

## Call if charge_and_attack() should cancel its attack
func cancel_attack():
	_attack_canceled = true

func charge_and_attack(amount: float, knockback: bool, body = null):
	if can_attack():
		charge_attack()
		await _attack_charge_timer.timeout
		if _attack_canceled:
			_attack_canceled = false
			return
		attack(amount, knockback, body)

func can_attack():
	return _attack_cooldown_timer.time_left == 0 and _attack_charge_timer.time_left == 0 and _attack_duration_timer.time_left == 0 and _stun_timer.time_left == 0

func is_attacking():
	return _attack_duration_timer.time_left != 0

func stun():
	cancel_attack()
	_stun_timer.start(stun_time)

func _attack_charge_timer_timeout():
	charge_end.emit()