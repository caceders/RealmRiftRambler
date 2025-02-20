class_name ItemDropper extends Node
# Assumed to be child of entity thats a child of world node where resource should spawn

@export var item_drop_spread = 8
@export var item_pool: Array[ResourceWeightPair]

@onready var item_drop_packed_scene: PackedScene = preload("res://Tools/ItemSystem/itemDrop.tscn")

func drop(amount: int = 1):
	for i in range(amount):
		var item = ResourceWeightPair.pick_random_weighted(item_pool)
		var item_drop = item_drop_packed_scene.instantiate()
		item_drop.global_position = get_parent().global_position
		item_drop.item = item
		var item_one_off_lerp_mover = OneOffLerpMover.new()
		item_one_off_lerp_mover.target_position = get_parent().global_position + Vector2(randf_range(-item_drop_spread, item_drop_spread), randf_range(-item_drop_spread, item_drop_spread))
		item_drop.add_child(item_one_off_lerp_mover)
		get_parent().add_sibling(item_drop)
