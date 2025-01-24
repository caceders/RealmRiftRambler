class_name WorldChunkGenerator extends Node2D

const TILE_SIZE_PIXELS = 8
const CHUNK_SIZE_TILES = 16
const CHUNK_SIZE_PIXELS = TILE_SIZE_PIXELS * CHUNK_SIZE_TILES

@export var noise: FastNoiseLite
@export var tile_map_layer: TileMapLayer
@export var camera_to_generate_around: Camera2D
@export var generation_infos : Array[GenerationParameters]

func generate_chunk(coord: Vector2i):
	var start_tile = coord * CHUNK_SIZE_TILES
	var tiles = []
	for x in range(start_tile.x, start_tile.x + CHUNK_SIZE_TILES):
		for y in range(start_tile.y, start_tile.y + CHUNK_SIZE_TILES):
			tiles.append(Vector2i(x,y))

	var terrain_array_dict = {}
	for tile in tiles:
		var noise_value = noise.get_noise_2d(tile.x, tile.y)
		for generation_info in generation_infos:
			if noise_value.x >= generation_info.low_noise_val:
				tile_map_layer.set_cell(tile, generation_info.source_id, generation_info.atlas_cord, generation_info.alternative_tile)
				terrain_array_dict[generation_info.terrain].append([tile, generation_info.terrain_set])
			
	## Connect all terrains
	for key in terrain_array_dict:
		tile_map_layer.set_cells_terrain_connect(terrain_array_dict[key][0], terrain_array_dict[key][1], key)
