class_name WorldChunkLoader extends TileMapLayer

const TILE_SIZE_PIXELS = 8
const CHUNK_SIZE_TILES = 8
const CHUNK_SIZE_PIXELS = TILE_SIZE_PIXELS * CHUNK_SIZE_TILES

@export var tile_map_layer: TileMapLayer
@export var camera_to_load_around: Camera2D

func store_chunk(coord: Vector2i) -> String:
	## Serialize tiles
	var start_tile = coord * CHUNK_SIZE_TILES
	var tiles = []
	for x in range(start_tile.x, start_tile.x + CHUNK_SIZE_TILES):
		for y in range(start_tile.y, start_tile.y + CHUNK_SIZE_TILES):
			tiles.append(Vector2i(x,y))
	
	var tile_datas = []
	for tile in tiles:
		tile_datas.append(serialize_tile(tile))
		## Remove tile
		tile_map_layer.set_cell(tile)
	
	## Serialize entities
	var all_entities = get_children()
	var entities_in_chunk = []
	for entity in all_entities:
		if position_to_chunk(entity.global_position) == coord:
			entities_in_chunk.append(entity)

	var entity_datas = []
	for entity in entities_in_chunk:
		if not "Player" in entity.get_groups():
			entity_datas.append(serialize_entity(entity))
			entity.queue_free()

	var chunk_data = {}
	chunk_data["tiles"] = tile_datas
	chunk_data["entities"] = entity_datas

	var chunk_data_string = JSON.stringify(chunk_data)
	return chunk_data_string

func load_chunk(chunk_data_string: String):
	var json = JSON.new()
	var parse_result = json.parse(chunk_data_string)
	if parse_result != OK:
		return {}
	var chunk_data = json.data as Dictionary
	
	## load tiles
	for tile_datas_string in chunk_data["tiles"]:
		var tile_data = deserialize_tile(tile_datas_string)
		tile_map_layer.set_cell(str_to_var(tile_data["coordinate"]), str_to_var(tile_data["source_id"]), str_to_var(tile_data["atlas_coords"]), str_to_var(tile_data["alternative_tile"]))
	
	## load entities
	for entity_data_string in chunk_data["entities"]:
		var entity = deserialize_entity(entity_data_string)
		add_child(entity)

func serialize_tile(tile_coordinate: Vector2i) -> String:
	var tile_data = {}
	tile_data["coordinate"] = var_to_str(tile_coordinate)
	tile_data["source_id"] = var_to_str(tile_map_layer.get_cell_source_id(tile_coordinate))
	tile_data["atlas_coords"] = var_to_str(tile_map_layer.get_cell_atlas_coords(tile_coordinate))
	tile_data["alternative_tile"] = var_to_str(tile_map_layer.get_cell_alternative_tile(tile_coordinate))
	
	var tile_data_string = JSON.stringify(tile_data)
	return tile_data_string

func deserialize_tile(tile_data_string: String) -> Dictionary:
	var json = JSON.new()
	var parse_result = json.parse(tile_data_string)
	if parse_result != OK:
		return {}
	var tile_data = json.data as Dictionary
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
	var entity_packed_scene = load(entity_data["packed_scene"]) as PackedScene
	var entity = entity_packed_scene.instantiate()
	entity.global_position = str_to_var(entity_data["position"])
	var persistant_data = str_to_var(entity_data["persistant_data"]) as Array[PersistantData]
	if not persistant_data.is_empty():
		for data in persistant_data:
			var subnode = entity.get_node(data.node_path)
			subnode.set(data.property, data.value)
	return entity

static func position_to_tile(p_position: Vector2) -> Vector2i:
	var tile: Vector2i = floor(p_position / TILE_SIZE_PIXELS)
	return tile

static func position_to_chunk(p_position: Vector2) -> Vector2i:
	var chunk: Vector2i = floor(p_position / CHUNK_SIZE_PIXELS)
	return chunk

static func tile_to_chunk(p_position: Vector2) -> Vector2i:
	var chunk: Vector2i = p_position / CHUNK_SIZE_TILES
	return chunk

static func get_chunks_in(tile_start: Vector2i, tile_end: Vector2i):
	var chunks = []
	var chunk_start = tile_start/CHUNK_SIZE_TILES
	var chunk_end = tile_end/CHUNK_SIZE_TILES + Vector2i(-2, -2)
	for x in range(chunk_start.x, chunk_end.x, sign(chunk_end.x - chunk_start.x)):
		for y in range(chunk_start.y, chunk_end.y, sign(chunk_end.y - chunk_start.y)):
			chunks.append(Vector2i(x,y))
	
	return chunks
