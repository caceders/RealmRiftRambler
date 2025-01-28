class_name Knockback extends Node2D

@onready var entity: TopDownEntity2D = self.get_parent().get_node("TopDownEntity2D")

@export var enable_knockback: bool = true

func knockback(from_entity: Node2D):
	if enable_knockback:
		entity.add_impulse((global_position - from_entity.global_position).normalized())

func on_damage_taken(amount: float, p_knockback: bool, damage_dealer: DamageDealer):
	if p_knockback:
		knockback(damage_dealer)
