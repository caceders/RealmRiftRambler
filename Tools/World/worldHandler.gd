class_name WorldHandler extends WorldChunkManipulator

const UPDATE_FRAMES = 2
const UPDATE_CHUNK_BATCH = 2

@export var load_distance : int = 5
@export var center_camera: Camera2D

@export var world_chunk_loader: WorldChunkLoader
@export var world_chunk_generator: WorldChunkGenerator
@export var entity_exit_world_handler: EntityExitWorldHandler

var _center_chunk : Vector2i = Vector2i(0,0)
var _active_chunks : Array[Vector2i] = []

var _chunks_to_store : Array[Vector2i] = []
var _chunks_to_load : Array[Vector2i] = []
var _chunks_to_generate : Array[Vector2i] = []
var _chunks_to_update: Array[Vector2i] = []
var _chunk_datas: Dictionary = {}


func _ready():
	generate_everything_immidiately()

func _process(_delta):
	update_chunk_arrays()
	if Engine.get_frames_drawn() % UPDATE_FRAMES == 0:
		# Prioritize loading chunks over generating and prioritize loading and generating chunks over storing
		if not _chunks_to_load.is_empty():
			load_chunks()
		elif not _chunks_to_generate.is_empty():
			generate_chunks()
		elif not _chunks_to_store.is_empty():
			store_chunks()
	uppdate_terrains()
	entity_exit_world_handler.handle_entities_outise_world_border()

func generate_everything_immidiately():
	update_chunk_arrays()
	while not _chunks_to_load.is_empty():
		load_chunks()
	while not _chunks_to_generate.is_empty():
		generate_chunks()
	while not _chunks_to_store.is_empty():
		store_chunks()
	while not _chunks_to_update.is_empty():
		uppdate_terrains()
	entity_exit_world_handler.handle_entities_outise_world_border()

func update_chunk_arrays():
	_center_chunk = world_chunk_loader.position_to_chunk(center_camera.global_position)
	
	var chunk_load_x_start = _center_chunk.x - load_distance
	var chunk_load_y_start = _center_chunk.y - load_distance
	var chunk_load_x_end = (_center_chunk.x + load_distance + 1)
	var chunk_load_y_end = (_center_chunk.y + load_distance + 1)

	## add chunks in load distance to load or generate
	var chunks_in_load_distance = []
	for x in range(chunk_load_x_start, chunk_load_x_end):
		for y in range(chunk_load_y_start, chunk_load_y_end):
			var chunk_coord = Vector2i(x,y)
			chunks_in_load_distance.append(chunk_coord)
	
	for chunk_coord in chunks_in_load_distance:
		if chunk_coord not in _active_chunks and chunk_coord not in _chunks_to_load and chunk_coord not in _chunks_to_generate:
			if _chunk_datas.has(chunk_coord):
				_chunks_to_load.append(chunk_coord)
			else:
				_chunks_to_generate.append(chunk_coord)

	## remove chunks outside load distance from load and generate
	## generate
	var chunks_remove_from_generate = []
	for chunk_coord in _chunks_to_generate:
		if chunk_coord not in chunks_in_load_distance:
			chunks_remove_from_generate.append(chunk_coord)
	
	for chunk in chunks_remove_from_generate:
		_chunks_to_generate.erase(chunk)

	## load
	var chunks_remove_from_load = []
	for chunk_coord in _chunks_to_load:
		if chunk_coord not in chunks_in_load_distance:
			chunks_remove_from_load.append(chunk_coord)
	
	for chunk in chunks_remove_from_load:
		_chunks_to_load.erase(chunk)

	_chunks_to_generate.sort_custom(sort_smallest_distance_from_camera)
	_chunks_to_load.sort_custom(sort_smallest_distance_from_camera)

	## add chunks to store
	for chunk_coord in _active_chunks:
		if chunk_coord not in chunks_in_load_distance and chunk_coord not in _chunks_to_store:
				_chunks_to_store.append(chunk_coord)
	
	var chunks_remove_from_store = []
	for chunk in _chunks_to_store:
		if chunk in chunks_in_load_distance:
			chunks_remove_from_store.append(chunk)

	for chunk in chunks_remove_from_store:
		_chunks_to_store.erase(chunk)

	_chunks_to_store.sort_custom(sort_greatest_distance_from_camera)

func store_chunks():
	var chunks_handled = 0
	while not _chunks_to_store.is_empty() and chunks_handled < UPDATE_CHUNK_BATCH:
		var chunk = _chunks_to_store.pop_back()
		_chunk_datas[chunk] = world_chunk_loader.store_chunk(chunk)
		_active_chunks.erase(chunk)
		_chunks_to_update.append(chunk)
		chunks_handled += 1

func load_chunks():
	var chunks_handled = 0
	while not _chunks_to_load.is_empty() and chunks_handled < UPDATE_CHUNK_BATCH:
		var chunk = _chunks_to_load.pop_back()
		world_chunk_loader.load_chunk(_chunk_datas[chunk])
		_active_chunks.append(chunk)
		_chunks_to_update.append(chunk)
		chunks_handled += 1


func generate_chunks():
	var chunks_handled = 0
	while not _chunks_to_generate.is_empty() and chunks_handled < UPDATE_CHUNK_BATCH:
		var chunk = _chunks_to_generate.pop_back()
		world_chunk_generator.generate_chunk(chunk)
		_active_chunks.append(chunk)
		_chunks_to_update.append(chunk)
		chunks_handled += 1

func uppdate_terrains():
	var tiles = []
	var chunks_handled = 0
	while not _chunks_to_update.is_empty() and chunks_handled < UPDATE_CHUNK_BATCH:
		var chunk = _chunks_to_update.pop_back()
		tiles.append_array(get_tiles_in(chunk))
		chunks_handled += 1
	BetterTerrain.update_terrain_cells(ground_tile_map_layer, tiles)
	BetterTerrain.update_terrain_cells(entity_tile_map_layer, tiles)

func re_store_chunk(chunk: Vector2i):
	if _chunk_datas.has(chunk):
		world_chunk_loader.load_chunk(_chunk_datas[chunk])
	else:
		world_chunk_generator.generate_chunk(chunk) 
	_chunk_datas[chunk] = world_chunk_loader.store_chunk(chunk)

func get_active_chunks():
	return _active_chunks.duplicate(true)

func sort_smallest_distance_from_camera(chunk1: Vector2i, chunk2: Vector2i):
	return (chunk1 * CHUNK_SIZE_PIXELS).distance_squared_to(center_camera.global_position) > (chunk2 * CHUNK_SIZE_PIXELS).distance_squared_to(center_camera.global_position)

func sort_greatest_distance_from_camera(chunk1: Vector2i, chunk2: Vector2i):
	return (chunk1 * CHUNK_SIZE_PIXELS).distance_squared_to(center_camera.global_position) < (chunk2 * CHUNK_SIZE_PIXELS).distance_squared_to(center_camera.global_position)
