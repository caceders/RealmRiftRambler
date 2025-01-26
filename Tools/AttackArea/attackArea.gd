class_name 	AttackArea extends Area2D

@onready var owner_body: CollisionObject2D = self.get_parent()

func attack_body(amount, knockback, damage_dealer, body):
	var target_damage_receiver = body.get_node("DamageReceiver")
	damage_dealer.deal_damage(amount, knockback, target_damage_receiver)

func attack_nearest_body_in_group(amount, knockback, damage_dealer, group = "Damagable"):
	var bodies_in_group = []
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group(group) and body != owner_body:
			bodies_in_group.append(body)
	if not bodies_in_group.is_empty():
		var nearest_distance = INF
		var target_damage_receiver: DamageReceiver
		for body in bodies_in_group:
			var distance = global_position.distance_to(body.global_position)
			if distance < nearest_distance:
				target_damage_receiver = body.get_node("DamageReceiver")
		if target_damage_receiver != null:
			damage_dealer.deal_damage(amount, knockback, target_damage_receiver)
	return bodies_in_group


func attack_all_bodies_in_group(amount, knockback, damage_dealer, group = "Damagable"):
	var bodies_in_group = []
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group(group) and body != owner_body:
			bodies_in_group.append(body)
			var target_damage_receiver = body.get_node("DamageReceiver")
			damage_dealer.deal_damage(amount, knockback, target_damage_receiver)
	return bodies_in_group

func is_body_in_attack_range(body: Node2D):
	return body in get_overlapping_bodies()
