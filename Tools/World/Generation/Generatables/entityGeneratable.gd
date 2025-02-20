class_name EntityGeneratable extends Generatable

@export var scenes: Array[ResourceWeightPair] = []
@export var is_entity_tile = false
@export var terrain_id: int

func apply_generatable(cell: Vector2i, world_chunk_generator: WorldChunkGenerator, only_update_extra_info: bool, better_terrain_changeset_paint_entity: Dictionary, better_terrain_changeset_paint_ground: Dictionary):
	var noise_pos: Vector2i = cell
	# Skip cell if noise not over generation floor
	if noise.get_noise_2d(noise_pos.x, noise_pos.y) < generation_noise_floor:
		return
	
	# Skip if tile that is already spawned hinders the creation of this tile
	if not _can_generate_on_cell(cell, world_chunk_generator):
		return

	# Place the entities
	if not (only_update_extra_info or only_extra_info):
		if is_entity_tile:
			if better_terrain_changeset_paint_entity != null:
				better_terrain_changeset_paint_entity[cell] = terrain_id
			else:
				BetterTerrain.set_cell(entity_tile_map_layer, cell, terrain_id)
		else:
			var packed_scene = ResourceWeightPair.pick_random_weighted(scenes)
			var scene = packed_scene.instantiate() as Node2D
			entity_tile_map_layer.add_child(scene)
			var position_offset = Vector2.ONE * randf_range(-CELL_SIZE_PIXELS/3, CELL_SIZE_PIXELS/3) # Add slight offset in case there are other entities here. Make them not stuck on eachother.
			scene.position = entity_tile_map_layer.map_to_local(cell) + position_offset
			
	apply_new_extra_tile_data(cell)
