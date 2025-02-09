class_name WorldChunkGenerator extends WorldChunkManipulator

@export var generatables: Array[Generatable] = []

func generate_chunk(chunk_coordinate: Vector2i):
	var tile_types = {}
	var tiles = get_tiles_in(chunk_coordinate)

	for generatable in generatables:
		# Place generatable
		for tile in tiles:
			var noise_pos = tile
			if generatable.is_4x4:
				# make 4 by 4 tiles together to match with tileset
				if noise_pos.x % 2 != 0: noise_pos.x -= 1
				if noise_pos.y % 2 != 0: noise_pos.y -= 1

			## Skip if noise not over generation floor
			if generatable.noise.get_noise_2d(noise_pos.x, noise_pos.y) < generatable.generation_noise_floor:
				continue

			if generatable.placement_type == generatable.PlacementType.ENTITY:
				_place_entity(tile, generatable, tile_types)
			else:
				## tile_types[tile] is not guaranteed to exist. Check if not exists or if generatable can generate on anything 
				if not tile_types.has(tile) or generatable.can_generate_on_anything:
					_place_tile(tile, generatable, tile_types)

				## if generatable cannot generate on everything and tile has a tiletype then check the tiletype
				elif tile_types[tile] in generatable.can_generate_on_tiles:
					_place_tile(tile, generatable, tile_types)

func _place_tile(tile, generatable, tile_types):
	if generatable.placement_type == generatable.PlacementType.TERRAIN:
		var tile_map_layer: TileMapLayer
		if generatable.tile_map_layer_type == generatable.TileMapLayerType.GROUND:
			tile_map_layer = ground_tile_map_layer
		elif generatable.tile_map_layer_type == generatable.TileMapLayerType.ENTITIES:
			tile_map_layer = entity_tile_map_layer
		BetterTerrain.set_cell(tile_map_layer, tile, generatable.tile_type)
		tile_types[tile] = generatable.tile_type

	if generatable.placement_type == generatable.PlacementType.TILE_TYPE_ONLY:
		tile_types[tile] = generatable.tile_type

func _place_entity(tile: Vector2i, generatable: Generatable, tile_types: Dictionary):
	
	var packed_scene = generatable.pick_random_scene_weighted()
	var scene = packed_scene.instantiate() as Node2D
	entity_tile_map_layer.add_child(scene)
	var occupies_tiles = null
	if scene is ScenePlacer:
		occupies_tiles = scene.get_all_occupied_tiles(entity_tile_map_layer)
	else:
		occupies_tiles = _get_all_occupied_tiles(scene)
	var can_spawn = true
	if not generatable.can_generate_on_anything:
		for occupied_tile in occupies_tiles:
			if tile_types.has(tile + occupied_tile):
				if not tile_types[tile + occupied_tile] in generatable.can_generate_on_tiles:
					can_spawn = false
					break
			else:
				var tile_type = _get_tile_pre_generation(tile)
				if tile_type not in generatable.can_generate_on_tiles:
					can_spawn = false
					break


	if can_spawn:
		tile_types[tile] = generatable.TileType.ENTITY
		scene.position = entity_tile_map_layer.map_to_local(tile)
	else:
		scene.queue_free()


func _get_all_occupied_tiles(entity: Node2D) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	if not entity.has_node("HitBox"):
		return []
	var hitbox = entity.get_node("HitBox") as HitBox
	var top_left = (entity.global_position - hitbox.circle_shape.radius*Vector2.ONE/2)
	var bottom_right = (entity.global_position + hitbox.circle_shape.radius*Vector2.ONE/2)
	var start_tile = entity_tile_map_layer.local_to_map(top_left)
	var end_tile = entity_tile_map_layer.local_to_map(bottom_right)
	for x in range(start_tile.x, end_tile.x + 1):
		for y in range(start_tile.y, end_tile.y + 1):
			tiles.append(Vector2i(x,y))
		
	
	return tiles

func _get_tile_pre_generation(tile) -> Generatable.TileType:
	var tile_type: Generatable.TileType
	for generatable in generatables:
		var noise_pos = tile
		if generatable.is_4x4:
			# make 4 by 4 tiles together to match with tileset
			if noise_pos.x % 2 != 0: noise_pos.x -= 1
			if noise_pos.y % 2 != 0: noise_pos.y -= 1

		## Skip if noise not over generation floor
		if generatable.noise.get_noise_2d(tile.x, tile.y) < generatable.generation_noise_floor:
			continue
		else:
			if generatable.can_generate_on_anything or tile_type in generatable.can_generate_on_tiles:
				if generatable.placement_type == generatable.PlacementType.TERRAIN:
					tile_type = generatable.tile_type
				if generatable.placement_type == generatable.PlacementType.TILE_TYPE_ONLY:
					tile_type = generatable.tile_type
	return tile_type
