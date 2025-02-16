class_name WorldHandler extends WorldChunkManipulator

const INCREASE_CHUNK_BATCH_CALCULATION_PER_CHUNK = 300

@export var load_distance : int = 5
@export var center_camera: Camera2D

@export var world_chunk_loader: WorldChunkLoader
@export var world_chunk_generator: WorldChunkGenerator

const UPDATE_FRAMES = 12
var _center_chunk : Vector2i = Vector2i(0,0)
var _active_chunks : Array[Vector2i] = []

var _chunks_to_store : Array[Vector2i] = []
var _chunks_to_load : Array[Vector2i] = []
var _chunks_to_generate : Array[Vector2i] = []
var _chunk_datas: Dictionary = {}

var better_terrain_changeset_paint_ground: Dictionary = {}
var better_terrain_changeset_paint_entity: Dictionary = {}

var better_terrain_changeset_ground
var better_terrain_changeset_entity

func _ready():
	create_new_terrain_changeset_paint_ground()
	create_new_terrain_changeset_paint_entity()
	generate_everything_immidiately()
	
func _process(_delta):
	_update_chunk_arrays()

	# Prioritize loading chunks over generating and prioritize loading and generating chunks over storing.
	if not _chunks_to_load.is_empty() and Engine.get_frames_drawn() % UPDATE_FRAMES == 0:
		_load_chunks()
	elif not _chunks_to_generate.is_empty() and (Engine.get_frames_drawn() + UPDATE_FRAMES/3) % UPDATE_FRAMES == 0:
		_generate_chunks()
	elif not _chunks_to_store.is_empty() and (Engine.get_frames_drawn() + (2*UPDATE_FRAMES/3)) % UPDATE_FRAMES == 0:
		_store_chunks()
	_uppdate_terrains()
	_handle_entities_outside_load_distance()

func generate_everything_immidiately():
	_update_chunk_arrays()
	while not _chunks_to_load.is_empty():
		_load_chunks()
	while not _chunks_to_generate.is_empty():
		_generate_chunks()
	while not _chunks_to_store.is_empty():
		_store_chunks()
	_uppdate_terrains()
	_handle_entities_outside_load_distance()

func create_new_terrain_changeset_paint_ground():
	better_terrain_changeset_paint_ground = {}
	world_chunk_loader.better_terrain_changeset_paint_ground = better_terrain_changeset_paint_ground
	world_chunk_generator.better_terrain_changeset_paint_ground = better_terrain_changeset_paint_ground

func create_new_terrain_changeset_paint_entity():
	better_terrain_changeset_paint_entity = {}
	world_chunk_loader.better_terrain_changeset_paint_entity = better_terrain_changeset_paint_entity
	world_chunk_generator.better_terrain_changeset_paint_entity = better_terrain_changeset_paint_entity

func _update_chunk_arrays():
	_center_chunk = world_chunk_loader.position_to_chunk(center_camera.global_position)
	
	var chunk_load_x_start = _center_chunk.x - load_distance
	var chunk_load_y_start = _center_chunk.y - load_distance
	var chunk_load_x_end = _center_chunk.x + load_distance
	var chunk_load_y_end = _center_chunk.y + load_distance

	# Add chunks in load distance to load or generate.
	var chunks_in_load_distance = []
	for x in range(chunk_load_x_start, chunk_load_x_end + 1):
		for y in range(chunk_load_y_start, chunk_load_y_end + 1):
			var chunk_coord = Vector2i(x,y)
			chunks_in_load_distance.append(chunk_coord)
	
	for chunk_coord in chunks_in_load_distance:
		if chunk_coord not in _active_chunks and chunk_coord not in _chunks_to_load and chunk_coord not in _chunks_to_generate:
			if _chunk_datas.has(chunk_coord):
				_chunks_to_load.append(chunk_coord)
			else:
				_chunks_to_generate.append(chunk_coord)

	# Remove chunks outside load distance from load and generate arrays.
	# Remove from generate array.
	var chunks_remove_from_generate = []
	for chunk_coord in _chunks_to_generate:
		if chunk_coord not in chunks_in_load_distance:
			chunks_remove_from_generate.append(chunk_coord)
	
	for chunk in chunks_remove_from_generate:
		_chunks_to_generate.erase(chunk)

	# Remove from load array.
	var chunks_remove_from_load = []
	for chunk_coord in _chunks_to_load:
		if chunk_coord not in chunks_in_load_distance:
			chunks_remove_from_load.append(chunk_coord)
	
	for chunk in chunks_remove_from_load:
		_chunks_to_load.erase(chunk)


	# Add chunks to store.
	for chunk_coord in _active_chunks:
		if chunk_coord not in chunks_in_load_distance and chunk_coord not in _chunks_to_store:
				_chunks_to_store.append(chunk_coord)
	
	var chunks_remove_from_store = []
	for chunk in _chunks_to_store:
		if chunk in chunks_in_load_distance:
			chunks_remove_from_store.append(chunk)

	for chunk in chunks_remove_from_store:
		_chunks_to_store.erase(chunk)

	# Prioritize chunks close to the camera
	_chunks_to_generate.sort_custom(sort_smallest_distance_from_camera)
	_chunks_to_load.sort_custom(sort_smallest_distance_from_camera)
	_chunks_to_store.sort_custom(sort_greatest_distance_from_camera)

func _store_chunks():
	var chunks_handled_this_frame = 0
	while not _chunks_to_store.is_empty() and chunks_handled_this_frame < _get_dynamic_update_chunk_batch_in_single_frame():
		var chunk = _chunks_to_store.pop_back()
		_chunk_datas[chunk] = world_chunk_loader.store_chunk(chunk)
		_active_chunks.erase(chunk)
		chunks_handled_this_frame += 1

func _load_chunks():
	var chunks_handled_this_frame = 0
	while not _chunks_to_load.is_empty() and chunks_handled_this_frame < _get_dynamic_update_chunk_batch_in_single_frame():
		var chunk = _chunks_to_load.pop_back()
		world_chunk_loader.load_chunk(_chunk_datas[chunk])
		_active_chunks.append(chunk)
		chunks_handled_this_frame += 1

func _generate_chunks():
	var chunks_handled_this_frame = 0
	while not _chunks_to_generate.is_empty() and chunks_handled_this_frame < _get_dynamic_update_chunk_batch_in_single_frame():
		var chunk = _chunks_to_generate.pop_back()
		world_chunk_generator.generate_chunk(chunk)
		_active_chunks.append(chunk)
		chunks_handled_this_frame += 1

func _uppdate_terrains():

	if better_terrain_changeset_ground == null:
		better_terrain_changeset_ground = BetterTerrain.create_terrain_changeset(ground_tile_map_layer, better_terrain_changeset_paint_ground)
	if better_terrain_changeset_entity == null:
		better_terrain_changeset_entity = BetterTerrain.create_terrain_changeset(entity_tile_map_layer, better_terrain_changeset_paint_entity)

	if BetterTerrain.is_terrain_changeset_ready(better_terrain_changeset_ground):
		BetterTerrain.apply_terrain_changeset(better_terrain_changeset_ground)
		better_terrain_changeset_ground = BetterTerrain.create_terrain_changeset(ground_tile_map_layer, better_terrain_changeset_paint_ground)
		create_new_terrain_changeset_paint_ground()
		
	if BetterTerrain.is_terrain_changeset_ready(better_terrain_changeset_entity):
		BetterTerrain.apply_terrain_changeset(better_terrain_changeset_entity)
		better_terrain_changeset_entity = BetterTerrain.create_terrain_changeset(entity_tile_map_layer, better_terrain_changeset_paint_entity)
		create_new_terrain_changeset_paint_entity()
		

func _handle_entities_outside_load_distance():
	# If entity exist outside loaded chunks - load or generate the relevant chunk and store it now with the entity	
	var all_entities = entity_tile_map_layer.get_children()
	var deloaded_chunks_to_update = []
	for entity in all_entities:
		if entity.is_queued_for_deletion():
			continue
		var chunk = position_to_chunk(entity.global_position)
		if chunk not in _active_chunks:
			if chunk not in deloaded_chunks_to_update:
				deloaded_chunks_to_update.append(chunk)
			
	for chunk in deloaded_chunks_to_update:
		generate_or_load_chunk_immidiately(chunk)

func generate_or_load_chunk_immidiately(chunk: Vector2i):
	if _chunk_datas.has(chunk):
		world_chunk_loader.load_chunk(_chunk_datas[chunk])
		if _chunks_to_load.has(chunk):
			_chunks_to_load.erase(chunk)
	else:
		world_chunk_generator.generate_chunk(chunk)
		if _chunks_to_generate.has(chunk):
			_chunks_to_generate.erase(chunk)
	_active_chunks.append(chunk)

func _get_dynamic_update_chunk_batch_in_single_frame():
	var num_chunks_to_treat = _chunks_to_store.size() + _chunks_to_load.size() + _chunks_to_generate.size()
	var batch_size = 1 + (num_chunks_to_treat * num_chunks_to_treat/INCREASE_CHUNK_BATCH_CALCULATION_PER_CHUNK)
	return batch_size

func sort_smallest_distance_from_camera(chunk1: Vector2i, chunk2: Vector2i):
	return (chunk1 * CHUNK_SIZE_PIXELS).distance_squared_to(center_camera.global_position) > (chunk2 * CHUNK_SIZE_PIXELS).distance_squared_to(center_camera.global_position)

func sort_greatest_distance_from_camera(chunk1: Vector2i, chunk2: Vector2i):
	return (chunk1 * CHUNK_SIZE_PIXELS).distance_squared_to(center_camera.global_position) < (chunk2 * CHUNK_SIZE_PIXELS).distance_squared_to(center_camera.global_position)
