class_name EntityGeneratable extends Generatable

@export var scenes: Array[SceneProbabilityPair] = []
@export var is_entity_tile = false
@export var terrain_id: int

func apply_generatable(cell: Vector2i, world_chunk_generator: WorldChunkGenerator, only_update_extra_info: bool = false):
	var noise_pos: Vector2i = cell
	# Skip cell if noise not over generation floor
	if noise.get_noise_2d(noise_pos.x, noise_pos.y) < generation_noise_floor:
		return
	
	# Skip if tile that is already spawned hinders the creation of this tile
	if not _can_generate_on_cell(cell, world_chunk_generator):
		return

	# Place the entities
	if not only_update_extra_info:
		if is_entity_tile:
			BetterTerrain.set_cell(entity_tile_map_layer, cell, terrain_id)
		else:
			var packed_scene = pick_random_scene_weighted()
			var scene = packed_scene.instantiate() as Node2D
			entity_tile_map_layer.add_child(scene)
			var position_offset = Vector2.ONE * randf_range(-CELL_SIZE_PIXELS, CELL_SIZE_PIXELS) # Add slight offset in case there are other entities here. Make them not stuck on eachother.
			scene.position = entity_tile_map_layer.map_to_local(cell) + position_offset
			
	apply_new_extra_tile_data(cell)

func pick_random_scene_weighted() -> PackedScene:
	var total_weights = 0
	for scene_probability_pair in scenes:
		total_weights += scene_probability_pair.weight
	var random_point_in_total_weights = randf_range(0, total_weights)
	var current_weight_top = 0
	for scene_probability_pair in scenes:
		current_weight_top += scene_probability_pair.weight
		if random_point_in_total_weights < current_weight_top:
			return scene_probability_pair.scene
	return null