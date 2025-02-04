class_name WorldChunkGenerator extends WorldChunkManipulator

enum TileType {
	GROUND,
	WATER,
	GRASS,
	FLOWER,
	STANDING_STONE,
	FOREST,
	ENTITY,
}
@export_group("Water")
@export var water_noise: FastNoiseLite = FastNoiseLite.new()
@export var water_generation_floor: float = .5

@export_group("Grass")
@export var grass_noise: FastNoiseLite = FastNoiseLite.new()
@export var grass_generation_floor: float = 0

@export_group("Flower")
@export var flower_noise: FastNoiseLite = FastNoiseLite.new()
@export var flower_generation_floor: float = 0

@export_group("Standing stones")
@export var standing_stone_noise: FastNoiseLite = FastNoiseLite.new()
@export var standing_stone_generation_floor: float = 0
@export var standing_stone_packed_scenes: Array[PackedScene] = []

@export_group("Forest")
@export var forest_noise: FastNoiseLite = FastNoiseLite.new()
@export var forest_generation_floor: float = 0

@export_group("Tree")
@export var tree_noise: FastNoiseLite = FastNoiseLite.new()
@export var tree_generation_floor: float = .5
@export var trees_packed_scenes: Array[PackedScene] = []

@export_group("Animals")
@export var animal_noise: FastNoiseLite = FastNoiseLite.new()
@export var animal_generation_floor: float = .5
@export var animal_packed_scenes: Array[PackedScene] = []

@export_group("Enemy")
@export var enemy_noise: FastNoiseLite = FastNoiseLite.new()
@export var enemy_generation_floor: float = .5
@export var enemy_packed_scenes: Array[PackedScene] = []

func generate_chunk(chunk_coordinate: Vector2i):
	var tile_types = {}
	var tiles = get_tiles_in(chunk_coordinate)
	# Place ground
	for tile in tiles:
		BetterTerrain.set_cell(ground_tile_map_layer, tile, TileType.GROUND)
		tile_types[tile] = TileType.GROUND
	
	# Place water
	for tile in tiles:
		# make 4 by 4 tiles have water together to match with tileset
		var noise_pos = tile
		if noise_pos.x % 2 != 0: noise_pos.x -= 1
		if noise_pos.y % 2 != 0: noise_pos.y -= 1

		if water_noise.get_noise_2d(noise_pos.x, noise_pos.y) > water_generation_floor:
			BetterTerrain.set_cell(ground_tile_map_layer, tile, TileType.WATER)
			tile_types[tile] = TileType.WATER

	# Place grass
	for tile in tiles:
		# make 4 by 4 tiles have grass together to match with tileset
		var noise_pos = tile
		if noise_pos.x % 2 != 0: noise_pos.x -= 1
		if noise_pos.y % 2 != 0: noise_pos.y -= 1

		if grass_noise.get_noise_2d(noise_pos.x, noise_pos.y) > grass_generation_floor and _is_tile_not_next_to_water_scaled(tile):
			BetterTerrain.set_cell(ground_tile_map_layer, tile, TileType.GRASS)
			tile_types[tile] = TileType.GRASS
	
	# Place flowers
	for tile in tiles:
		var noise_pos = tile

		if flower_noise.get_noise_2d(noise_pos.x, noise_pos.y) > flower_generation_floor and not _could_tile_be_water(tile):
			BetterTerrain.set_cell(entity_tile_map_layer, tile, TileType.FLOWER)
			tile_types[tile] = TileType.FLOWER
	
	# Place standing stones
	for tile in tiles:
		var noise_pos = tile

		if standing_stone_noise.get_noise_2d(noise_pos.x, noise_pos.y) > standing_stone_generation_floor and not _could_tile_be_water(tile):
			_place_entity(tile, standing_stone_packed_scenes, tile_types)

	# Place forest
	for tile in tiles:
		if forest_noise.get_noise_2d(tile.x, tile.y) > forest_generation_floor:
			if tile_types[tile] == TileType.WATER: continue
			tile_types[tile] = TileType.FOREST

	# Place trees
	for tile in tiles:
		if tree_noise.get_noise_2d(tile.x, tile.y) > tree_generation_floor and tile_types[tile] == TileType.FOREST:
			_place_entity(tile, trees_packed_scenes, tile_types)

	# Place animals
	for tile in tiles:
		if animal_noise.get_noise_2d(tile.x, tile.y) > animal_generation_floor:
			_place_entity(tile, animal_packed_scenes, tile_types)

	# Place enemies
	for tile in tiles:
		if enemy_noise.get_noise_2d(tile.x, tile.y) > enemy_generation_floor:
			_place_entity(tile, enemy_packed_scenes, tile_types)

func _place_entity(tile: Vector2i, packed_scenes: Array [PackedScene], tile_types: Dictionary):
	if packed_scenes.is_empty():
		return
	var packed_scene = packed_scenes.pick_random()
	if packed_scene == null:
		return
	var scene = packed_scene.instantiate() as Node2D
	entity_tile_map_layer.add_child(scene) 
	var occupies_tiles = scene.get_all_occupied_tiles(entity_tile_map_layer)
	var can_spawn = true
	for occupied_tile in occupies_tiles:
		if not tile_types.has(tile + occupied_tile):
			can_spawn = false
			break
		if tile_types[tile + occupied_tile] == TileType.WATER or tile_types[tile + occupied_tile] == TileType.ENTITY:
			can_spawn = false
			break
	if can_spawn:
		tile_types[tile] = TileType.ENTITY
		scene.position = entity_tile_map_layer.map_to_local(tile)
	else:
		scene.queue_free()

func _could_tile_be_water(tile):
	var noise_pos = tile
	if noise_pos.x % 2 != 0: noise_pos.x -= 1
	if noise_pos.y % 2 != 0: noise_pos.y -= 1
	if water_noise.get_noise_2d(noise_pos.x, noise_pos.y) > water_generation_floor:
		return true
	return false

func _is_tile_not_next_to_water(tile: Vector2i):
	if _could_tile_be_water(tile): return false
	if _could_tile_be_water(tile + Vector2i(1,0)): return false
	if _could_tile_be_water(tile + Vector2i(0,1)): return false
	if _could_tile_be_water(tile + Vector2i(-1,0)): return false
	if _could_tile_be_water(tile + Vector2i(0,-1)): return false
	return true

func _is_tile_not_next_to_water_scaled(tile: Vector2i):
	if tile.x % 2 != 0: tile.x -= 1
	if tile.y % 2 != 0: tile.y -= 1
	if _could_tile_be_water(tile + Vector2i(-1,-1)): return false
	if _could_tile_be_water(tile + Vector2i(0,-1)): return false
	if _could_tile_be_water(tile + Vector2i(1,-1)): return false
	if _could_tile_be_water(tile + Vector2i(2,-1)): return false
	if _could_tile_be_water(tile + Vector2i(-1,0)): return false
	if _could_tile_be_water(tile + Vector2i(0,0)): return false
	if _could_tile_be_water(tile + Vector2i(1,0)): return false
	if _could_tile_be_water(tile + Vector2i(2,0)): return false
	if _could_tile_be_water(tile + Vector2i(-1,1)): return false
	if _could_tile_be_water(tile + Vector2i(0,1)): return false
	if _could_tile_be_water(tile + Vector2i(1,1)): return false
	if _could_tile_be_water(tile + Vector2i(2,1)): return false
	if _could_tile_be_water(tile + Vector2i(-1,2)): return false
	if _could_tile_be_water(tile + Vector2i(0,2)): return false
	if _could_tile_be_water(tile + Vector2i(1,2)): return false
	if _could_tile_be_water(tile + Vector2i(2,2)): return false

	return true

func _is_tile_occupied(tile_types: Dictionary, tile:Vector2i):
	if tile_types[tile] == TileType.WATER : return true
	if tile_types[tile] == TileType.ENTITY : return true
	return false