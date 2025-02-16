class_name GroundGeneratable extends Generatable

# Make 4 by 4 tiles together to match with tileset that are not fully connected
@export var is_4x4: bool = false
@export var terrain_id: int

func apply_generatable(cell: Vector2i, world_chunk_generator: WorldChunkGenerator, only_update_extra_info: bool, better_terrain_changeset_paint_entity: Dictionary, better_terrain_changeset_paint_ground: Dictionary):
	var noise_pos: Vector2i = cell
	
	if is_4x4:
		if noise_pos.x % 2 != 0: noise_pos.x -= 1
		if noise_pos.y % 2 != 0: noise_pos.y -= 1
	## Skip cell if noise not over generation floor
	if noise.get_noise_2d(noise_pos.x, noise_pos.y) < generation_noise_floor:
		return
	## Skip if tile that is already spawned hinders the creation of this tile
	if not _can_generate_on_cell(cell, world_chunk_generator):
		return
	if not (only_update_extra_info or only_extra_info):
		if better_terrain_changeset_paint_ground != null:
			better_terrain_changeset_paint_ground[cell] = terrain_id
		else:
			BetterTerrain.set_cell(ground_tile_map_layer, cell, terrain_id)

	apply_new_extra_tile_data(cell)
