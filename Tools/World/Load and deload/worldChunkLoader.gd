class_name WorldChunkLoader extends WorldChunkManipulator

const CONSTANT_LOADED_GROUPS = ["Player"]

func store_chunk(coord: Vector2i):
	# Store tiles
	var start_tile = coord * CHUNK_SIZE_TILES
	var tiles = []
	for x in range(start_tile.x, start_tile.x + CHUNK_SIZE_TILES):
		for y in range(start_tile.y, start_tile.y + CHUNK_SIZE_TILES):
			tiles.append(Vector2i(x,y))
	
	var ground_tile_datas = []
	for tile in tiles:
		var tile_data = {}
		var tile_id = BetterTerrain.get_cell(ground_tile_map_layer, tile)
		# Dont store empty tiles
		if tile_id == -1: continue
		tile_data["coordinate"] = tile
		tile_data["terrain_id"] = tile_id
		ground_tile_datas.append(tile_data)
		# Remove tile
		BetterTerrain.set_cell(ground_tile_map_layer, tile, -1)
	
	var entity_tile_datas = []
	for tile in tiles:
		var tile_data = {}
		var tile_id = BetterTerrain.get_cell(entity_tile_map_layer, tile)
		# Dont store empty tiles
		if tile_id == -1: continue
		tile_data["coordinate"] = tile
		tile_data["terrain_id"] = tile_id
		entity_tile_datas.append(tile_data)
		# Remove tile
		BetterTerrain.set_cell(entity_tile_map_layer, tile, -1)
	
	
	# Store entities
	var all_entities = entity_tile_map_layer.get_children()
	var entities_in_chunk = []
	for entity in all_entities:
		if position_to_chunk(entity.global_position) == coord:
			entities_in_chunk.append(entity)

	var entity_datas = []
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
				deload_persistant_data = deload_persistance.deload_persistant_data
			
			var entity_data = {}
			entity_data["packed_scene"] = packed_scene
			entity_data["position"] = node_position
			entity_data["persistant_data"] = deload_persistant_data
			entity_datas.append(entity_data)
			entity.queue_free()

	# Store chunk
	var chunk_data = {}
	chunk_data["ground_tiles"] = ground_tile_datas
	chunk_data["entity_tiles"] = entity_tile_datas
	chunk_data["entities"] = entity_datas
	return chunk_data

func load_chunk(chunk_data: Dictionary):

	## load ground tiles
	for tile_data in chunk_data["ground_tiles"]:
		BetterTerrain.set_cell(ground_tile_map_layer, tile_data["coordinate"], tile_data["terrain_id"])
	
	## load entity tiles
	for tile_data in chunk_data["entity_tiles"]:
		BetterTerrain.set_cell(entity_tile_map_layer, tile_data["coordinate"], tile_data["terrain_id"])
	
	## load entities
	for entity_data in chunk_data["entities"]:
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

func serialize_tile(tile_coordinate: Vector2i) -> String:
	var tile_data = {}
	tile_data["coordinate"] = tile_coordinate
	tile_data["terrain_id"] = BetterTerrain.get_cell(ground_tile_map_layer, tile_coordinate)
	
	var tile_data_string = JSON.stringify(tile_data)
	return tile_data_string

func deserialize_tile(tile_data_string: String) -> Dictionary:
	var json = JSON.new()
	var parse_result = json.parse(tile_data_string)
	if parse_result != OK:
		return {}
	var tile_data = json.data as Dictionary
	tile_data["coordinate"] = str_to_var(tile_data["coordinate"])
	tile_data["source_id"] = str_to_var(tile_data["source_id"])
	tile_data["atlas_coords"] = str_to_var(tile_data["atlas_coords"])
	tile_data["alternative_tile"] = str_to_var(tile_data["alternative_tile"])
	return tile_data

func serialize_entity(node: Node2D) -> String:
	var packed_scene = node.scene_file_path
	var node_position = node.global_position

	var deload_persistant_data = []
	if node.has_node("DeloadPersistance"):
		var deload_persistance = node.get_node("DeloadPersistance") as DeloadPersistance
		deload_persistant_data = deload_persistance.deload_persistant_data
	
	var entity_data = {}
	entity_data["packed_scene"] = packed_scene
	entity_data["position"] = var_to_str(node_position)
	entity_data["persistant_data"] = var_to_str(deload_persistant_data)
	var entity_data_string = JSON.stringify(entity_data)
	return entity_data_string

func deserialize_entity(entity_data_string) -> Node2D:
	var json = JSON.new()
	var parse_result = json.parse(entity_data_string)
	if parse_result != OK:
		return null

	var entity_data = json.data as Dictionary
	entity_data["packed_scene"] = str_to_var(entity_data["packed_scene"])
	entity_data["position"] = str_to_var(entity_data["position"])
	entity_data["persistant_data"] = str_to_var(entity_data["persistant_data"])

	var entity_packed_scene = load(entity_data["packed_scene"]) as PackedScene
	var entity = entity_packed_scene.instantiate()
	entity.global_position = entity_data["position"]
	var persistant_data = entity_data["persistant_data"] as Array[PersistantData]
	
	if not persistant_data.is_empty():
		for data in persistant_data:
			var subnode = entity.get_node(data.node_path)
			subnode.set(data.property, data.value)
	return entity
