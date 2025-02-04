class_name Player extends CharacterBody2D

const PAUSE_REGENERATION_HURT_TIME = 5
const BASE_ATTACK_AMOUNT = 50 
const INVINSIBILITY_TIME = .5

enum State {PASSIVE,
			SPELLCASTING,
			HURT,
			DYING,
			DEAD,
}

enum Direction {
	LEFT,
	RIGHT,
}


@onready var player_entity: TopDownEntity2D = $TopDownEntity2D
@onready var animation_player_controller: AnimationPlayerController = $AnimationPlayerController
@onready var health: DamageReceiver = $DamageReceiver
@onready var hitbox: CollisionShape2D = $HitBox
@onready var invincibility_manager: InvincibilityManager = $InvincibilityManager
@onready var knockback: Knockback = $Knockback
@onready var sprite: Sprite2D = $Sprite2D
@onready var spell_caster: SpellCaster = $SpellCaster
@onready var key_sequence_recoder: keySequenceRecoder = $KeySequenceRecoder
@onready var sequence_decoder: SequenceDecoder = $SequenceDecoder
@onready var targeter: Targeter = $Targeter

var _active_state = State.PASSIVE
var _last_movement_direction = Direction.LEFT
var _damaged_flag = false

func _ready():
	animation_player_controller.play_base_animation("playerIdleLeft")
	_enter_state(State.PASSIVE)


func _process(_delta):
	_state_process()
	

func _state_process():
	match _active_state:
		State.PASSIVE:
			if health.amount == 0:
				_enter_state(State.DYING)
				return
			elif _damaged_flag:
				_enter_state(State.HURT)
				return
			elif key_sequence_recoder.is_inputing_sequence():
				_enter_state(State.SPELLCASTING)
				return
			if Input.is_action_just_pressed("switch target"):
				targeter.start_lock_on()

			if Input.is_action_just_released("switch target"):
				targeter.end_lock_on()
				targeter.select_next_target()
			_movement()
			return
		State.HURT:
			_enter_state(State.PASSIVE)
			return
		State.SPELLCASTING:
			if health.amount == 0:
				_enter_state(State.DYING)
				return
			elif _damaged_flag:
				_enter_state(State.HURT)
				return
			# Cast spell
			elif Input.is_action_just_pressed("attack"):
				spell_caster.target = targeter.target
				var sequence = key_sequence_recoder.get_sequence()
				var spell = sequence_decoder.decode_keycode(sequence)
				if spell == null:
					_enter_state(State.PASSIVE)
					return
				spell_caster.cast(spell)
				if _last_movement_direction == Direction.LEFT:
					animation_player_controller.play_overlay_animation("playerAttackLeft", 1)
				elif _last_movement_direction == Direction.RIGHT:
					animation_player_controller.play_overlay_animation("playerAttackRight", 1)
				_enter_state(State.PASSIVE)
				return
			elif not key_sequence_recoder.is_inputing_sequence():
				_enter_state(State.PASSIVE)
				return
			
			# Stop casting and move
			elif Input.get_vector("maneuver_left", "maneuver_right", "maneuver_up", "maneuver_down") != Vector2.ZERO:
				_enter_state(State.PASSIVE)
			return
		State.DYING:
			_enter_state(State.DEAD)
		State.DEAD:
			return


func _enter_state(state: State):
	_exit_state(_active_state)
	_active_state = state

	#For every state
	player_entity.stop()

	match _active_state:
		State.PASSIVE:
			return
		State.HURT:
			_damaged_flag = false
			invincibility_manager.activate_invincibility_for_time(INVINSIBILITY_TIME)
			return
		State.SPELLCASTING:
			_animate_spellcast()
			return
		State.DYING:
			return
		State.DEAD:
			sprite.visible = false
			return


func _exit_state(state: State):
	match state:
		State.PASSIVE:
			return
		State.SPELLCASTING:
			key_sequence_recoder.clear()
			return
		State.DYING:
			return
		State.DEAD:
			sprite.visible = true
			return

func ressurect():
	health.amount = health.max_amount
	_enter_state(State.PASSIVE)

func _movement():
	# Set direction
	var movement_direction = Input.get_vector("maneuver_left", "maneuver_right", "maneuver_up", "maneuver_down")
	player_entity.direction = movement_direction

	# Get direction for animation
	if Input.is_action_pressed("maneuver_left"):
		_last_movement_direction = Direction.LEFT
	elif Input.is_action_pressed("maneuver_right"):
		_last_movement_direction = Direction.RIGHT

	# Animate
	if _last_movement_direction == Direction.LEFT:
		if player_entity.is_moving:
			animation_player_controller.play_base_animation("playerWalkLeft")
		else:
			animation_player_controller.play_base_animation("playerIdleLeft")

	if _last_movement_direction == Direction.RIGHT:
		if player_entity.is_moving:
			animation_player_controller.play_base_animation("playerWalkRight")
		else:
			animation_player_controller.play_base_animation("playerIdleRight")


func _on_damage_received(_amount: float, p_knockback: bool, damage_dealer: DamageDealer):
	_damaged_flag = true
	if _last_movement_direction == Direction.LEFT:
		animation_player_controller.play_overlay_animation("playerHurtLeft", 2 )
	else:
		animation_player_controller.play_overlay_animation("playerHurtRight", 2 )


func _animate_spellcast():
	if _last_movement_direction == Direction.LEFT:
		animation_player_controller.play_base_animation("playerSpellCastLeft")
	else:
		animation_player_controller.play_base_animation("playerSpellCastRight")
