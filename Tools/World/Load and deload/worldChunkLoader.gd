class_name WorldChunkLoader extends WorldChunkManipulator

const CONSTANT_LOADED_GROUPS = ["Player"]

func store_chunk(chunk_coordinate: Vector2i):
		
	var ground_tile_datas = _transform_all_ground_tiles_to_datas_in_chunk(chunk_coordinate)
	var entity_tile_datas = _transform_all_entity_tiles_to_datas_in_chunk(chunk_coordinate)
	var entity_datas = _transform_all_entities_to_datas_in_chunk(chunk_coordinate)
	
	var chunk_data = {}
	chunk_data["ground_tiles"] = ground_tile_datas
	chunk_data["entity_tiles"] = entity_tile_datas
	chunk_data["entities"] = entity_datas
	return chunk_data

func load_chunk(chunk_data: Dictionary):

	# Load ground tiles.
	for tile_data in chunk_data["ground_tiles"]:
		BetterTerrain.set_cell(ground_tile_map_layer, tile_data["coordinate"], tile_data["terrain_id"])
		ground_tile_map_layer.set_extra_data(tile_data["coordinate"], tile_data["extra_data"])
	
	# Load entity tiles.
	for tile_data in chunk_data["entity_tiles"]:
		BetterTerrain.set_cell(entity_tile_map_layer, tile_data["coordinate"], tile_data["terrain_id"])
	
	# Load entities.
	for entity_data in chunk_data["entities"]:
		if not ResourceLoader.exists(entity_data["packed_scene"]):
			continue
		var entity_packed_scene = load(entity_data["packed_scene"]) as PackedScene
		if entity_packed_scene == null:
			continue
		var entity = entity_packed_scene.instantiate()
		entity.global_position = entity_data["position"]
		var persistant_data = entity_data["persistant_data"] as Array[PersistantData]
		if not persistant_data.is_empty():
			for data in persistant_data:
				var subnode = entity.get_node(data.node_path)
				subnode.set(data.property, data.value)
		entity_tile_map_layer.add_child(entity)

func _transform_all_ground_tiles_to_datas_in_chunk(chunk_coordinate: Vector2i) -> Array[Dictionary]:
	var cells = get_cells_in(chunk_coordinate)

	var tile_datas:Array[Dictionary] = []
	for cell in cells:
		var tile_data = {}
		var tile_id = BetterTerrain.get_cell(ground_tile_map_layer, cell)
		var extra_data = ground_tile_map_layer.get_extra_data(cell)
		ground_tile_map_layer.remove_extra_data(cell)
		# Dont store empty tiles.
		if tile_id == -1: continue
		tile_data["coordinate"] = cell
		tile_data["terrain_id"] = tile_id
		tile_data["extra_data"] = extra_data
		tile_datas.append(tile_data)
		# Remove tile.
		BetterTerrain.set_cell(ground_tile_map_layer, cell, -1)
	return tile_datas

func _transform_all_entity_tiles_to_datas_in_chunk(chunk_coordinate: Vector2i) -> Array[Dictionary]:
	var cells = get_cells_in(chunk_coordinate)

	var tile_datas:Array[Dictionary] = []
	for cell in cells:
		var tile_data = {}
		var tile_id = BetterTerrain.get_cell(entity_tile_map_layer, cell)
		# Dont store empty tiles.
		if tile_id == -1: continue
		tile_data["coordinate"] = cell
		tile_data["terrain_id"] = tile_id
		tile_datas.append(tile_data)
		# Remove tile.
		BetterTerrain.set_cell(entity_tile_map_layer, cell, -1)
	return tile_datas

func _transform_all_entities_to_datas_in_chunk(chunk_coordinate: Vector2i) -> Array[Dictionary]:
	# Get all entities in the chunk.
	var all_entities = entity_tile_map_layer.get_children()
	var entities_in_chunk = []
	for entity in all_entities:
		if position_to_chunk(entity.global_position) == chunk_coordinate:
			entities_in_chunk.append(entity)

	# Store the relevant ones.
	var entity_datas:Array[Dictionary] = []
	for entity in entities_in_chunk:
		var should_store = true

		if entity.is_queued_for_deletion():
			should_store = false

		for group in entity.get_groups():
			if group in CONSTANT_LOADED_GROUPS:
				should_store = false

		if should_store:
			var packed_scene = entity.scene_file_path
			var node_position = entity.global_position

			var deload_persistant_data = []
			if entity.has_node("DeloadPersistance"):
				var deload_persistance = entity.get_node("DeloadPersistance") as DeloadPersistance
				deload_persistant_data = deload_persistance.deload_persistant_data.duplicate(true)
			
			var entity_data = {}
			entity_data["packed_scene"] = packed_scene
			entity_data["position"] = node_position
			entity_data["persistant_data"] = deload_persistant_data
			entity_datas.append(entity_data)
			entity.queue_free()
	return entity_datas
