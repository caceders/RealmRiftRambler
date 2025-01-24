class_name WorldChunkHandler extends Node

@export var chunk_folder = "EntityChunks"
@export var world_chunk_loader: WorldChunkLoader
@export var world_chunk_generator: WorldChunkGenerator
@export var center: Node2D
@export var load_distance : int = 5
@export var store_distance : int = 7

var _center_chunk : Vector2i
var loaded_chunks : Array[Vector2i] = []

var chunks_to_load : Array[Vector2i] = []
var chunks_to_store : Array[Vector2i] = []

func _ready():
	update_world_chunks()

func _process(delta):
	chunk_load_store()
	if center != null:
		var new_center = WorldChunkLoader.position_to_chunk(center.global_position)
		_center_chunk = new_center
		update_world_chunks()

func chunk_load_store():
		load_and_generate_chunks()
		store_chunks()

func update_world_chunks():
	var chunk_load_x_start = _center_chunk.x - load_distance
	var chunk_load_y_start = _center_chunk.y - load_distance
	var chunk_load_x_end = (_center_chunk.x + load_distance + 1)
	var chunk_load_y_end = (_center_chunk.y + load_distance + 1)

	var chunk_store_x_start = _center_chunk.x - store_distance
	var chunk_store_y_start = _center_chunk.y - store_distance
	var chunk_store_x_end = (_center_chunk.x + store_distance + 1)
	var chunk_store_y_end = (_center_chunk.y + store_distance + 1)

	## add chunks to load
	for x in range(chunk_load_x_start, chunk_load_x_end):
		for y in range(chunk_load_y_start, chunk_load_y_end):
			var chunk_coord = Vector2i(x,y)
			if chunk_coord not in loaded_chunks and chunk_coord not in chunks_to_load:
				chunks_to_load.append(chunk_coord)

	## add chunks to store
	for chunk_coord in loaded_chunks:
		if chunk_coord.x < chunk_store_x_start or chunk_coord.x > chunk_store_x_end or chunk_coord.y < chunk_store_y_start or chunk_coord.y > chunk_store_y_end:
			if chunk_coord not in chunks_to_store:
				chunks_to_store.append(chunk_coord)
	
func load_and_generate_chunks():
	while not chunks_to_load.is_empty():
		var chunk_coord = chunks_to_load.pop_front()
		var chunk_file = FileAccess.open(chunk_folder + "/" + var_to_str(chunk_coord) + ".json", FileAccess.READ) as FileAccess
		if chunk_file != null:
			world_chunk_loader.load_chunk(chunk_file.get_as_text())
			chunk_file.close()
		elif world_chunk_generator != null:
			world_chunk_generator.generate_chunk(chunk_coord)

		loaded_chunks.append(chunk_coord)

func store_chunks():
	while not chunks_to_store.is_empty():
		var chunk_coord = chunks_to_store.pop_front()
		var chunk_file = FileAccess.open(chunk_folder + "/" + var_to_str(chunk_coord) + ".json",  FileAccess.WRITE) as FileAccess
		if chunk_file != null:
			chunk_file.store_string(world_chunk_loader.store_chunk(chunk_coord))
			chunk_file.close()
		loaded_chunks.erase(chunk_coord)
