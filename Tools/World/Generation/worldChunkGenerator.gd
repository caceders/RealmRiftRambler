class_name WorldChunkGenerator extends WorldChunkManipulator

@export var generatables: Array[Generatable] = []

func generate_chunk(chunk_coordinate: Vector2i):
	var tile_types = {}
	var tiles = get_tiles_in(chunk_coordinate)
	# If a tile is used for a premade generatable, dont override it
	var tiles_with_premade_generatable = []
	for generatable in generatables:
		# Place generatable
		for tile in tiles:
			if tile in tiles_with_premade_generatable:
				continue
			var noise_pos: Vector2i = tile
			if generatable.placement_type == generatable.PlacementType.PREMADE:
				# map entire premade scene to one single pixel on whitenoise. Integer division okay
				noise_pos.x = noise_pos.x / generatable.premade_world_size.x
				noise_pos.y = noise_pos.y / generatable.premade_world_size.y

			elif generatable.is_4x4:
				# make 4 by 4 tiles together to match with tileset
				if noise_pos.x % 2 != 0: noise_pos.x -= 1
				if noise_pos.y % 2 != 0: noise_pos.y -= 1

			## Skip if noise not over generation floor
			if generatable.noise.get_noise_2d(noise_pos.x, noise_pos.y) < generatable.generation_noise_floor:
				continue
			
			elif generatable.placement_type == generatable.PlacementType.PREMADE:
				_handle_premade(generatable, tile, tile_types, tiles_with_premade_generatable)

			elif generatable.placement_type == generatable.PlacementType.ENTITY:
				_place_entity(tile, generatable, tile_types)
			else:
				## tile_types[tile] is not guaranteed to exist. Check if not exists or if generatable can generate on anything 
				if not tile_types.has(tile) or generatable.can_generate_on_anything:
					_place_tile(tile, generatable, tile_types)

				## if generatable cannot generate on everything and tile has a tiletype then check the tiletype
				elif tile_types[tile] in generatable.can_generate_on_tiles:
					_place_tile(tile, generatable, tile_types)

func _handle_premade(generatable, tile : Vector2i, tile_types, tiles_with_premade_generatable):
	## Get all world tiles used by premade generatable and check them
	## Find the top left tile by integer division and then multiplication.

	var world_top_left_tile: Vector2i = generatable.premade_world_size * tile / generatable.premade_world_size
	
	var can_spawn = _can_premade_spawn(generatable, tile, tile_types, world_top_left_tile)
	if can_spawn:
		var tile_in_premade_x = generatable.premade_top_left_corner.x + fposmod(tile.x, generatable.premade_world_size.x)
		var tile_in_premade_y = generatable.premade_top_left_corner.y + fposmod(tile.y, generatable.premade_world_size.y)

		var tile_in_premade: Vector2i = Vector2i(tile_in_premade_x, tile_in_premade_y)
		
		var preload_chunk = tile_to_chunk(Vector2i(tile_in_premade_x, tile_in_premade_y))

		var preload_chunk_data = generatable.premade_world_chunk_datas[preload_chunk]
		## load ground tiles	
		for tile_data in preload_chunk_data["ground_tiles"]:
			if tile_data["coordinate"] == tile_in_premade:
				BetterTerrain.set_cell(ground_tile_map_layer, tile, tile_data["terrain_id"])
		
		## load entity tiles
		for tile_data in preload_chunk_data["entity_tiles"]:
			if tile_data["coordinate"] == tile_in_premade:
				BetterTerrain.set_cell(entity_tile_map_layer, tile, tile_data["terrain_id"])
		
		## load entities
		for entity_data in preload_chunk_data["entities"]:
			if position_to_tile(entity_data["position"]) == tile_in_premade:
				var entity_packed_scene = load(entity_data["packed_scene"]) as PackedScene
				if entity_packed_scene == null:
					continue
				var entity = entity_packed_scene.instantiate()
				# Move the position to the position in local world coordinates
				entity.global_position = entity_data["position"] - (tile_in_premade as Vector2) * TILE_SIZE_PIXELS + (tile as Vector2) * TILE_SIZE_PIXELS
				var persistant_data = entity_data["persistant_data"] as Array[PersistantData]
				if not persistant_data.is_empty():
					for data in persistant_data:
						var subnode = entity.get_node(data.node_path)
						subnode.set(data.property, data.value)
				entity_tile_map_layer.add_child(entity)
		
		tiles_with_premade_generatable.append(tile)
	
	## Store all the tiles used by the premade generatable to save computation time in future
	## Able to spawn
	if can_spawn and not generatable.able_to_spawn_on_tiles.has(tile):
		for tile_x in range(world_top_left_tile.x, world_top_left_tile.x + generatable.premade_world_size.x):
			for tile_y in range(world_top_left_tile.y, world_top_left_tile.y + generatable.premade_world_size.y):
				var add_tile = Vector2i(tile_x, tile_y)
				generatable.able_to_spawn_on_tiles[add_tile] = "yah"
	## Unable to spawn
	elif not can_spawn and not generatable.unable_to_spawn_on_tiles.has(tile):
		for tile_x in range(world_top_left_tile.x, world_top_left_tile.x + generatable.premade_world_size.x):
			for tile_y in range(world_top_left_tile.y, world_top_left_tile.y + generatable.premade_world_size.y):
				var add_tile = Vector2i(tile_x, tile_y)
				generatable.unable_to_spawn_on_tiles[add_tile] = "nah"
	## Remove handled tiles
	if can_spawn:
		generatable.able_to_spawn_on_tiles.erase(tile)
	if not can_spawn:
		generatable.unable_to_spawn_on_tiles.erase(tile)

func _can_premade_spawn(generatable, tile, tile_types, world_top_left_tile):
	if generatable.able_to_spawn_on_tiles.has(tile): ## We've made the calculations for this tile before. We can conclude early that we CAN spawn
		return true
	elif generatable.unable_to_spawn_on_tiles.has(tile): ## We've made the calculations for this tile before. We can conclude early that we CANT spawn
		return false
	elif not generatable.can_generate_on_anything:
		for tile_x in range(world_top_left_tile.x, world_top_left_tile.x + generatable.premade_world_size.x):
			for tile_y in range(world_top_left_tile.y, world_top_left_tile.y + generatable.premade_world_size.y):
				var check_tile = Vector2i(tile_x, tile_y)
				if tile_types.has(check_tile):
					if not tile_types[check_tile] in generatable.can_generate_on_tiles:
						return false
				else:
					if not _get_tile_pre_generation(check_tile, generatable) in generatable.can_generate_on_tiles:
						return false
	return true

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
				var tile_type = _get_tile_pre_generation(tile, generatable)
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

func _get_tile_pre_generation(tile, p_generatable) -> Generatable.TileType:
	var tile_type: Generatable.TileType = Generatable.TileType.GROUND

	for generatable in generatables:
		# If the current generatable is the noe passed in the parameter, retun the tiletype. We are done with everything that generates before this one.
		if generatable == p_generatable:
			return tile_type
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
