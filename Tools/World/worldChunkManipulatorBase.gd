class_name WorldChunkManipulator extends Node

const CELL_SIZE_PIXELS = 8
const CHUNK_SIZE_CELLS = 6
const CHUNK_SIZE_PIXELS = CELL_SIZE_PIXELS * CHUNK_SIZE_CELLS

@export var ground_tile_map_layer: TileMapLayerWithTileData
@export var entity_tile_map_layer: TileMapLayerWithTileData

func position_to_cell(p_position: Vector2) -> Vector2i:
	var cell = ground_tile_map_layer.local_to_map(p_position)
	return cell

func position_to_chunk(p_position: Vector2) -> Vector2i:
	var chunk: Vector2i = cell_to_chunk(position_to_cell(p_position))
	return chunk

func cell_to_chunk(p_position: Vector2) -> Vector2i:
	var ccell: Vector2i = floor(p_position / CHUNK_SIZE_CELLS)
	return ccell

func get_chunks_in(cell_start: Vector2i, cell_end: Vector2i):
	var chunks = []
	var chunk_start = cell_to_chunk(cell_start)
	var chunk_end = cell_to_chunk(cell_end)
	# Need to go from start to and inclusive end
	for x in range(chunk_start.x, chunk_end.x + 1):
		for y in range(chunk_start.y, chunk_end.y + 1):
			chunks.append(Vector2i(x,y))
	
	return chunks

func get_cells_in(chunk_coord: Vector2i):
	var cells = []
	var cells_start = chunk_coord * CHUNK_SIZE_CELLS
	# Need to go from start to and inclusive end, therefore pluss vector one
	var cells_end = (chunk_coord + Vector2i.ONE) * CHUNK_SIZE_CELLS
	for x in range(cells_start.x, cells_end.x):
		for y in range(cells_start.y, cells_end.y):
			cells.append(Vector2i(x,y))
	
	return cells