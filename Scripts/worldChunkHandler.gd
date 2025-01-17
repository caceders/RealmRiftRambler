class_name WorldChunkHandler extends Node

@export var chunk_folder = "Chunks"
@export var chunk_loader: ChunkLoader
@export var center: Node2D
@export var render_distance : int = 3

var _center_chunk : Vector2i
var loaded_chunks : Array[Vector2i] = []

var chunks_to_load : Array[Vector2i] = []
var chunks_to_store : Array[Vector2i] = []

func _process(delta):
	if center != null:
		var new_center = chunk_loader.position_to_chunk(center.global_position)
		if _center_chunk != new_center:
			_center_chunk = new_center
			update_world_chunks()

func chunk_load_store():
		load_chunks()
		store_chunks()

func update_world_chunks():
	var chunk_x_start = _center_chunk.x - render_distance
	var chunk_y_start = _center_chunk.y - render_distance
	var chunk_x_end = (_center_chunk.x + render_distance + 1)
	var chunk_y_end = (_center_chunk.y + render_distance + 1)

	## add chunks to load
	for x in range(chunk_x_start, chunk_x_end):
		for y in range(chunk_y_start, chunk_y_end):
			var chunk_coord = Vector2i(x,y)
			if chunk_coord not in loaded_chunks and chunk_coord not in chunks_to_load:
				chunks_to_load.append(chunk_coord)

	## add chunks to store
	for chunk_coord in loaded_chunks:
		if chunk_coord.x < chunk_x_start or chunk_coord.x > chunk_x_end or chunk_coord.y < chunk_y_start or chunk_coord.y > chunk_y_end:
			if chunk_coord not in chunks_to_store:
				chunks_to_store.append(chunk_coord)
	
func load_chunks():
	while not chunks_to_load.is_empty():
		var chunk_coord = chunks_to_load.pop_front()
		var chunk_file = FileAccess.open(chunk_folder + "/" + var_to_str(chunk_coord) + ".json", FileAccess.READ) as FileAccess
		if chunk_file != null:
			chunk_loader.load_chunk(chunk_file.get_as_text())
			chunk_file.close()

		loaded_chunks.append(chunk_coord)

func store_chunks():
	while not chunks_to_store.is_empty():
		var chunk_coord = chunks_to_store.pop_front()
		var chunk_file = FileAccess.open(chunk_folder + "/" + var_to_str(chunk_coord) + ".json",  FileAccess.WRITE) as FileAccess
		if chunk_file != null:
			chunk_file.store_string(chunk_loader.store_chunk(chunk_coord))
			chunk_file.close()
		loaded_chunks.erase(chunk_coord)
