class_name ResourceDropSpawn extends Node2D

@export var resource: PackedScene
@export var amount: int = 1
@export var drop_radius: float = 10

func drop():
	if resource != null:
		for i in range(amount):
			var resource_drop = resource.instantiate() as ResourceDrop
			resource_drop.global_position = global_position
			var one_off_lerp_mover = OneOffLerpMover.new() as OneOffLerpMover
			one_off_lerp_mover.target_position = Vector2(randf_range(-drop_radius + self.global_position.x, drop_radius+ self.global_position.x), randf_range(-drop_radius + self.global_position.y, drop_radius+ self.global_position.y))
			resource_drop.add_child(one_off_lerp_mover)
			# dont add the drop to the entity but the context the entity exist in
			get_parent().get_parent().add_child(resource_drop)
