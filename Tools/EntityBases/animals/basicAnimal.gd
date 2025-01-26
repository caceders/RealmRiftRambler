class_name BasicAnimal extends Node2D

enum Direction {
	LEFT,
	RIGHT,
}

@export var health_regen_pause_time: float = 10
@onready var top_down_entity_2D: TopDownEntity2D = $TopDownEntity2D
@onready var health: DamageReceiver = $DamageReceiver
@onready var animation_player_controller: AnimationPlayerController = $AnimationPlayerController

var _last_movement_direction = Direction.LEFT

func _ready():
	animation_player_controller.play_base_animation("animalIdleLeft")
	health.damage_received.connect(on_damage_taken)

func on_damage_taken(p_amount, knockback, damage_dealer):
	health.pause_growth_for(health_regen_pause_time)
	if _last_movement_direction == Direction.RIGHT:
		animation_player_controller.play_overlay_animation("animalHurtRight", 1)
	else:
		animation_player_controller.play_overlay_animation("animalHurtLeft", 1)

func _process(delta):
	if top_down_entity_2D.is_moving:
		if top_down_entity_2D.direction.x > 0:
			_last_movement_direction = Direction.RIGHT
			animation_player_controller.play_base_animation("animalWalkRight")
		else:
			_last_movement_direction = Direction.LEFT
			animation_player_controller.play_base_animation("animalWalkLeft")
	else:
		if _last_movement_direction == Direction.RIGHT:
			animation_player_controller.play_base_animation("animalIdleRight")
		else:
			animation_player_controller.play_base_animation("animalIdleLeft")
