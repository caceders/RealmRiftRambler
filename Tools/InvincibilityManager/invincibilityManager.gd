class_name InvincibilityManager extends Node2D

const OPACITY_CHANGE_TIME = .1

@export var health: DamageReceiver
@export var sprite: Sprite2D

var _invincibility_timer : Timer
var _invincible: bool = false
var _fading_out: bool = true

func _ready():
	_invincibility_timer = Timer.new()
	_invincibility_timer.one_shot = true
	add_child(_invincibility_timer)

func _process(delta):
	if _invincible:
		if _fading_out:
			var new_modulate_a = sprite.modulate.a - (delta)/(OPACITY_CHANGE_TIME)
			if new_modulate_a < 0: 
				new_modulate_a = 0
				_fading_out = false
			sprite.modulate.a = new_modulate_a
		
		else:
			var new_modulate_a = sprite.modulate.a + (delta)/(OPACITY_CHANGE_TIME)
			if new_modulate_a > 1: 
				new_modulate_a = 1
				_fading_out = true
			sprite.modulate.a = new_modulate_a


func activate_invincibility_for_time(time):
	_invincible = true
	health.ignore_all_damage = true
	_invincibility_timer.start(time)
	await _invincibility_timer.timeout
	_invincible = false
	health.ignore_all_damage = false
	sprite.modulate.a = 1


func activate_invincibility():
	_invincible = true
	health.ignore_all_damage = true


func deactivate_invincibility():
	_invincible = false
	health.ignore_all_damage = false
	sprite.modulate.a = 1