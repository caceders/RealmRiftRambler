class_name DamageDealer extends Node2D

func deal_damage(amount: float, knockback: bool, damage_receiver: DamageReceiver):
	damage_receiver.damage(amount, knockback, self)