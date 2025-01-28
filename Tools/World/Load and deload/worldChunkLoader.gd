class_name WorldChunkLoader extends TileMapLayer

const TILE_SIZE_PIXELS = 8
const CHUNK_SIZE_TILES = 8
const CHUNK_SIZE_PIXELS = TILE_SIZE_PIXELS * CHUNK_SIZE_TILES
const CONSTANT_LOADED_GROUPS = ["Player"]

@export var load_distance : int = 5
@export var center_camera: Camera2D

var _center_chunk : Vector2i = Vector2i(0,0)
var _loaded_chunks : Array[Vector2i] = []

var _chunks_to_load : Array[Vector2i] = []
var _chunks_to_store : Array[Vector2i] = []

var _chunk_datas: Dictionary = {}

func _input(event):
	# Check for a mouse click
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Get the global mouse position
		var world_position = get_global_mouse_position()
		
		# Convert the world position to tile coordinates
		var tile_position = local_to_map(world_position)
		
		# Display the tile position in the console
		print("Tile Position: ", tile_position)

		# Optional: Display the tile position on-screen
		display_tile_position_on_screen(tile_position)

func display_tile_position_on_screen(tile_position: Vector2i):
	# Create a label to show the position
	var label = Label.new()
	label.text = "Tile: %s" % str(tile_position)
	label.modulate = Color(1, 0, 0)  # Red text for visibility
	label.position = get_global_mouse_position()
	add_child(label)

func _process(_delta):
	update_world_chunks()
	store_chunks()
	load_chunks()

func update_preloaded_chunks():

	var used_rect = get_used_rect()

	print(var_to_str(used_rect.position)  + " and " + var_to_str(used_rect.end))

	var load_x_start = used_rect.position
	var load_x_end = used_rect.end
	var preloaded_chunks = get_chunks_in(load_x_start, load_x_end)
	_loaded_chunks.append_array(preloaded_chunks)

func update_world_chunks():
	_center_chunk = position_to_chunk(center_camera.global_position)
	
	var chunk_load_x_start = _center_chunk.x - load_distance
	var chunk_load_y_start = _center_chunk.y - load_distance
	var chunk_load_x_end = (_center_chunk.x + load_distance + 1)
	var chunk_load_y_end = (_center_chunk.y + load_distance + 1)

	## add chunks to load
	var chunks_in_load_distance = []
	for x in range(chunk_load_x_start, chunk_load_x_end):
		for y in range(chunk_load_y_start, chunk_load_y_end):
			var chunk_coord = Vector2i(x,y)
			chunks_in_load_distance.append(chunk_coord)
	
	for chunk_coord in chunks_in_load_distance:
		if chunk_coord not in _loaded_chunks and chunk_coord not in _chunks_to_load:
			_chunks_to_load.append(chunk_coord)

	## add chunks to store
	for chunk_coord in _loaded_chunks:
		if chunk_coord not in chunks_in_load_distance and chunk_coord not in _chunks_to_store:
				_chunks_to_store.append(chunk_coord)
	
func load_chunks():
	while not _chunks_to_load.is_empty():
		var chunk = _chunks_to_load.pop_back()
		_load_chunk(chunk)
		_loaded_chunks.append(chunk)

func store_chunks():
	while not _chunks_to_store.is_empty():
		var chunk = _chunks_to_store.pop_back()
		_store_chunk(chunk)
		_loaded_chunks.erase(chunk)

func get_loaded_chunks() -> Array[Vector2i]:
	return _loaded_chunks.duplicate(true)

func _store_chunk(coord: Vector2i):
	# Store tiles
	var start_tile = coord * CHUNK_SIZE_TILES
	var tiles = []
	for x in range(start_tile.x, start_tile.x + CHUNK_SIZE_TILES):
		for y in range(start_tile.y, start_tile.y + CHUNK_SIZE_TILES):
			tiles.append(Vector2i(x,y))
	
	var tile_datas = []
	for tile in tiles:
		var tile_data = {}
		tile_data["coordinate"] = tile
		tile_data["source_id"] = get_cell_source_id(tile)
		tile_data["atlas_coords"] = get_cell_atlas_coords(tile)
		tile_data["alternative_tile"] = get_cell_alternative_tile(tile)
		tile_datas.append(tile_data)
		# Remove tile
		set_cell(tile)
	
	# Store entities
	var all_entities = get_children()
	var entities_in_chunk = []
	for entity in all_entities:
		if position_to_chunk(entity.global_position) == coord:
			entities_in_chunk.append(entity)

	var entity_datas = []
	for entity in entities_in_chunk:
		if not "Player" in entity.get_groups():
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
	chunk_data["tiles"] = tile_datas
	chunk_data["entities"] = entity_datas
	_chunk_datas[coord] = chunk_data

func _load_chunk(coord: Vector2i):

	if not _chunk_datas.has(coord):
		return
	var chunk_data = _chunk_datas[coord]

	## load tiles
	for tile_data in chunk_data["tiles"]:
		set_cell(tile_data["coordinate"], tile_data["source_id"], tile_data["atlas_coords"], tile_data["alternative_tile"])
	
	## load entities
	for entity_data in chunk_data["entities"]:
		var entity_packed_scene = load(entity_data["packed_scene"]) as PackedScene
		var entity = entity_packed_scene.instantiate()
		entity.global_position = entity_data["position"]
		var persistant_data = entity_data["persistant_data"] as Array[PersistantData]
		if not persistant_data.is_empty():
			for data in persistant_data:
				var subnode = entity.get_node(data.node_path)
				subnode.set(data.property, data.value)
		add_child(entity)

func serialize_tile(tile_coordinate: Vector2i) -> String:
	var tile_data = {}
	tile_data["coordinate"] = var_to_str(tile_coordinate)
	tile_data["source_id"] = var_to_str(get_cell_source_id(tile_coordinate))
	tile_data["atlas_coords"] = var_to_str(get_cell_atlas_coords(tile_coordinate))
	tile_data["alternative_tile"] = var_to_str(get_cell_alternative_tile(tile_coordinate))
	
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

func position_to_tile(p_position: Vector2) -> Vector2i:
	var tile = local_to_map(p_position)
	return tile

func position_to_chunk(p_position: Vector2) -> Vector2i:
	var chunk: Vector2i = tile_to_chunk(position_to_tile(p_position))
	return chunk

func tile_to_chunk(p_position: Vector2) -> Vector2i:
	var chunk: Vector2i = floor(p_position / CHUNK_SIZE_TILES)
	return chunk

func get_chunks_in(tile_start: Vector2i, tile_end: Vector2i):
	var chunks = []
	var chunk_start = tile_to_chunk(tile_start)
	var chunk_end = tile_to_chunk(tile_end)
	# Need to go from start to and inclusive end
	for x in range(chunk_start.x, chunk_end.x + sign(chunk_end.x - chunk_start.x), sign(chunk_end.x - chunk_start.x)):
		for y in range(chunk_start.y, (chunk_end.y + sign(chunk_end.y - chunk_start.y)), sign(chunk_end.y - chunk_start.y)):
			chunks.append(Vector2i(x,y))
	
	return chunks