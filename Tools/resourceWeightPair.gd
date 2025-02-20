class_name ResourceWeightPair extends Resource
@export var resource: Resource
@export var weight: float = 1

static func pick_random_weighted(array: Array[ResourceWeightPair]):
	var total_weights = 0
	for resource_weight_pair in array:
		total_weights += resource_weight_pair.weight
	var random_point_in_total_weights = randf_range(0, total_weights)
	var current_weight_top = 0
	for resource_weight_pair in array:
		current_weight_top += resource_weight_pair.weight
		if random_point_in_total_weights < current_weight_top:
			return resource_weight_pair.resource
	return null