class_name PlainsMapGenerator extends MapGenerator

const GROUND_TILE_ATLAS = Vector2i(37, 11)
const GRASS_TILE_ATLAS = Vector2i(3, 4)
const GRASS_TILE_TERRAIN_ID = 5
const GRASS_SEED_OFFSET = 100023415

const WATER_TILE_ATLAS = Vector2i(26, 1)
const WATER_TILE_TERRAIN_ID = 2
const WATER_SEED_OFFSET = 67948123589
const WATER_NOISE_PLACEMENT_FLOOR = 0.3

const FOREST_SEED_OFFSET = 5265762372623
const TREE_TILE_ATLAS = Vector2i(26, 1)
const TREE_TILE_TERRAIN_ID = 1
const TREE_SEED_OFFSET = 23642542356
const FOREST_NOISE_PLACEMENT_FLOOR = 0.2
const TREE_NOISE_PLACEMENT_FLOOR = 0.3


const FLOWER_TILE_ATLAS = [Vector2i(9, 9), Vector2i(10, 9), Vector2i(11, 9)]
const FLOWER_SEED_OFFSET = 23642542356
const FLOWER_NOISE_PLACEMENT_FLOOR = 0.3


const CREATURE_PATTERN_ID = [0, 2]
const CREATURE_SEED_OFFSET = 4326225
const MIN_SPAWN_DISTANCE_ENEMIES_SQUARED = 100
const CREATURE_NOISE_PLACEMENT_FLOOR = 0.55


## Tilemmap is not perfectly edge or corner connected, but is designed for 2x2 terrains. When placing upscale the vector to place 2x2 tiles instead if just 1x1
const MAP_DOWNSCALE = 2

var _grass_tiles_downscaled = []
var _grass_tiles = []

var _water_tiles_downscaled = []
var _water_tiles = []

var _forest_tiles = []
var _tree_tiles = []
var _creature_tiles = []

func generate_world(map_size, object_tile_map_layer: TileMapLayer, tiles_tile_map_layer: TileMapLayer, map_seed, center):

	create_ground(map_size, tiles_tile_map_layer)
	place_water(map_size, tiles_tile_map_layer, map_seed, center)
	place_grass(map_size, tiles_tile_map_layer, map_seed)
	plant_trees(map_size, object_tile_map_layer, tiles_tile_map_layer, map_seed, center)
	plant_flowers(map_size, object_tile_map_layer, tiles_tile_map_layer, map_seed, center)
	place_creatures(map_size, object_tile_map_layer, tiles_tile_map_layer, map_seed, center)

	return

func create_ground(map_size, tiles_tile_map_layer: TileMapLayer):
	for x in range( -map_size, map_size):
		for y in range(-map_size, map_size):
			tiles_tile_map_layer.set_cell(Vector2i(x,y), 0, GROUND_TILE_ATLAS)

func place_grass(map_size, tiles_tile_map_layer: TileMapLayer, map_seed):
	var grass_noise = FastNoiseLite.new() as FastNoiseLite
	grass_noise.seed = map_seed + GRASS_SEED_OFFSET

	grass_noise.frequency = 0.05

	var downscaled_map = round (map_size / MAP_DOWNSCALE)

	for x in range( -downscaled_map, downscaled_map):
		for y in range(-downscaled_map, downscaled_map):
			var cell = Vector2i(x,y)

			if grass_noise.get_noise_2d(cell.x, cell.y) > 0:
				_grass_tiles_downscaled.append(cell)
				for x_i in range(MAP_DOWNSCALE):
					for y_i in range(MAP_DOWNSCALE):
						_grass_tiles.append(cell * MAP_DOWNSCALE + Vector2i(x_i, y_i))

	
	tiles_tile_map_layer.set_cells_terrain_connect(_grass_tiles, 0, GRASS_TILE_TERRAIN_ID)

func place_water(map_size, tiles_tile_map_layer: TileMapLayer, map_seed, center):

	var water_noise = FastNoiseLite.new() as FastNoiseLite
	var center_availability_offset = 0

	water_noise.frequency = 0.02
	water_noise.seed = map_seed + WATER_SEED_OFFSET + center_availability_offset

	# Make sure center is unoccupied
	while water_noise.get_noise_2d(center.x, center.y) > WATER_NOISE_PLACEMENT_FLOOR:
		center_availability_offset += 1 
		water_noise.seed = map_seed + WATER_SEED_OFFSET


	var downscaled_map = round (map_size / MAP_DOWNSCALE)

	for x in range( -downscaled_map, downscaled_map):
		for y in range(-downscaled_map, downscaled_map):
			var cell = Vector2i(x,y)
			
			if water_noise.get_noise_2d(cell.x, cell.y) > WATER_NOISE_PLACEMENT_FLOOR:
				_water_tiles_downscaled.append(cell)
				for x_i in range(MAP_DOWNSCALE):
					for y_i in range(MAP_DOWNSCALE):
						_water_tiles.append(cell * MAP_DOWNSCALE + Vector2i(x_i, y_i))

	
	tiles_tile_map_layer.set_cells_terrain_connect(_water_tiles, 0, WATER_TILE_TERRAIN_ID)

func plant_trees(map_size, object_tile_map_layer: TileMapLayer, tiles_tile_map_layer: TileMapLayer, map_seed, center):
	var forest_noise = FastNoiseLite.new() as FastNoiseLite
	forest_noise.frequency = 0.02

	var tree_noise = FastNoiseLite.new() as FastNoiseLite
	tree_noise.frequency = 1

	var center_availability_offset = 0
	forest_noise.seed = map_seed + FOREST_SEED_OFFSET + center_availability_offset
	tree_noise.seed = map_seed + TREE_SEED_OFFSET + center_availability_offset

	# Make sure center is unoccupied
	while forest_noise.get_noise_2d(center.x, center.y) > FOREST_NOISE_PLACEMENT_FLOOR and tree_noise.get_noise_2d(center.x, center.y) > TREE_NOISE_PLACEMENT_FLOOR:
		center_availability_offset += 1 
		forest_noise.seed = map_seed + FOREST_SEED_OFFSET + center_availability_offset
		tree_noise.seed = map_seed + TREE_SEED_OFFSET + center_availability_offset


	for x in range( -map_size, map_size):
		for y in range(-map_size, map_size):	
			var cell = Vector2i(x,y)
			if forest_noise.get_noise_2d(cell.x, cell.y) > FOREST_NOISE_PLACEMENT_FLOOR:
				_forest_tiles.append(cell)
	
	for cell in _forest_tiles:
		if tree_noise.get_noise_2d(cell.x, cell.y) > TREE_NOISE_PLACEMENT_FLOOR and not get_tile_is_occupied(cell):
			object_tile_map_layer.set_cell(cell, 1, Vector2i(0, 0), TREE_TILE_TERRAIN_ID)

func plant_flowers(map_size, object_tile_map_layer, tiles_tile_map_layer, map_seed, center):
	var flower_noise = FastNoiseLite.new() as FastNoiseLite
	flower_noise.frequency = 0.02

	flower_noise.seed = map_seed + FLOWER_SEED_OFFSET

	# Make sure center is unoccupied

	for x in range( -map_size, map_size):
		for y in range(-map_size, map_size):	
			var cell = Vector2i(x,y)
			if flower_noise.get_noise_2d(cell.x, cell.y) > FLOWER_NOISE_PLACEMENT_FLOOR and not get_tile_is_occupied(cell):
				object_tile_map_layer.set_cell(cell, 2, FLOWER_TILE_ATLAS.pick_random(), 0)

func place_creatures(map_size, object_tile_map_layer, tiles_tile_map_layer, map_seed, center):
	object_tile_map_layer.set_pattern(Vector2i(0,0), object_tile_map_layer.tile_set.get_pattern(0))
	var creature_noise = FastNoiseLite.new() as FastNoiseLite
	creature_noise.frequency = 1

	creature_noise.seed = map_seed + CREATURE_SEED_OFFSET

	var existing_entities = object_tile_map_layer.get_children()

	for x in range( -map_size, map_size):
		for y in range(-map_size, map_size):	
			var cell = Vector2i(x,y)
			if creature_noise.get_noise_2d(cell.x, cell.y) > CREATURE_NOISE_PLACEMENT_FLOOR :
				var can_spawn = true
				var pattern = object_tile_map_layer.tile_set.get_pattern(CREATURE_PATTERN_ID.pick_random()) as TileMapPattern
				var pattern_size = pattern.get_size()

				if cell.distance_squared_to(center) < MIN_SPAWN_DISTANCE_ENEMIES_SQUARED:
					can_spawn = false

				for local_cell in pattern.get_used_cells():
					if get_tile_is_occupied(cell + local_cell):
						can_spawn = false
				if can_spawn:
					object_tile_map_layer.set_pattern(cell, pattern)
					var used_local_cells = pattern.get_used_cells()
					for used_local_cell in used_local_cells:
						_creature_tiles.append(used_local_cell + cell)

func get_tile_is_occupied(cell: Vector2i):
	return (cell in _water_tiles or cell in _tree_tiles or cell in _creature_tiles)
