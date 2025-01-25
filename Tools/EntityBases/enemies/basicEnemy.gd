class_name BasicEnemy extends Node2D

enum Direction {
	LEFT,
	RIGHT,
}

@export var health_regen_pause_time: float = 10
@onready var top_down_entity_2D: TopDownEntity2D = $TopDownEntity2D
@onready var health: DamageReceiver = $DamageReceiver
@onready var animation_player_controller: AnimationPlayerController = $AnimationPlayerController
@onready var attack_controller: AttackController = $AttackController

var _last_movement_direction = Direction.LEFT
var _is_playing_charge_anim = false

func _ready():
	attack_controller.charge_started.connect(_on_charge_attack_started)
	attack_controller.charge_end.connect(_on_charge_attack_end)
	attack_controller.attack_started.connect(_on_attack_started)
	animation_player_controller.play_base_animation("enemyIdleLeft")
	health.damage_received.connect(on_damage_taken)

func on_damage_taken(p_amount, knockback, damage_dealer):
	health.pause_growth_for(health_regen_pause_time)
	if _last_movement_direction == Direction.RIGHT:
		animation_player_controller.play_overlay_animation("enemyHurtRight", 1)
	else:
		animation_player_controller.play_overlay_animation("enemyHurtLeft", 1)

func _process(delta):
	if top_down_entity_2D.is_moving:
		if top_down_entity_2D.direction.x > 0:
			_last_movement_direction = Direction.RIGHT
			if not _is_playing_charge_anim:
				animation_player_controller.play_base_animation("enemyWalkRight")
		else:
			_last_movement_direction = Direction.LEFT
			if not _is_playing_charge_anim:
				animation_player_controller.play_base_animation("enemyWalkLeft")
	elif not _is_playing_charge_anim:
		if _last_movement_direction == Direction.RIGHT:
			animation_player_controller.play_base_animation("enemyIdleRight")
		else:
			animation_player_controller.play_base_animation("enemyIdleLeft")
	
func _on_charge_attack_started():
	_is_playing_charge_anim = true
	if _last_movement_direction == Direction.RIGHT:
		animation_player_controller.play_base_animation("enemyChargeRight")
	else:
		animation_player_controller.play_base_animation("enemyChargeLeft")

func _on_charge_attack_end():
	_is_playing_charge_anim = false

func _on_attack_started():
	if _last_movement_direction == Direction.RIGHT:
		animation_player_controller.play_overlay_animation("enemyAttackRight", 1)
	else:
		animation_player_controller.play_overlay_animation("enemyAttackLeft", 1)
