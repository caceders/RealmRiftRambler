class_name WorldChunkManipulator extends Node

const TILE_SIZE_PIXELS = 8
const CHUNK_SIZE_TILES = 16
const CHUNK_SIZE_PIXELS = TILE_SIZE_PIXELS * CHUNK_SIZE_TILES

@export var ground_tile_map_layer: TileMapLayer
@export var entity_tile_map_layer: TileMapLayer

func position_to_tile(p_position: Vector2) -> Vector2i:
	var tile = ground_tile_map_layer.local_to_map(p_position)
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
	for x in range(chunk_start.x, chunk_end.x + 1):
		for y in range(chunk_start.y, chunk_end.y + 1):
			chunks.append(Vector2i(x,y))
	
	return chunks

func get_tiles_in(chunk_coord: Vector2i):
	var tiles = []
	var tiles_start = chunk_coord * CHUNK_SIZE_TILES
	var tiles_end = (chunk_coord + Vector2i.ONE) * CHUNK_SIZE_TILES
	# Need to go from start to and inclusive end
	for x in range(tiles_start.x, tiles_end.x):
		for y in range(tiles_start.y, tiles_end.y):
			tiles.append(Vector2i(x,y))
	
	return tiles