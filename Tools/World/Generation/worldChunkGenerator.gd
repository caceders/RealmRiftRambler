class_name WorldChunkGenerator extends WorldChunkManipulator

enum TileType {
	GROUND,
	WATER,
	GRASS,
	FOREST,
	TREE,
	ENTITY,
	ENEMIES,
}

@export var water_noise: FastNoiseLite
@export var water_generation_floor: float = .5

@export var grass_noise: FastNoiseLite
@export var grass_generation_floor: float = 0

@export var forest_noise: FastNoiseLite
@export var forest_generation_floor: float = 0

@export var tree_noise: FastNoiseLite
@export var tree_generation_floor: float = .5
@export var trees_packed_scenes: Array[PackedScene] = []

@export var entity_noise: FastNoiseLite
@export var entity_generation_floor: float = .5
@export var entity_packed_scenes: Array[PackedScene] = []

@export var enemy_noise: FastNoiseLite
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

		if grass_noise.get_noise_2d(noise_pos.x, noise_pos.y) > grass_generation_floor and _is_tile_next_to_water_scaled(tile):
			BetterTerrain.set_cell(ground_tile_map_layer, tile, TileType.GRASS)
			tile_types[tile] = TileType.GRASS

	# Place forest
	for tile in tiles:
		if forest_noise.get_noise_2d(tile.x, tile.y) > forest_generation_floor:
			if tile_types[tile] == TileType.WATER: continue
			tile_types[tile] = TileType.FOREST

	# Place trees
	for tile in tiles:
		if tree_noise.get_noise_2d(tile.x, tile.y) > tree_generation_floor and tile_types[tile] == TileType.FOREST:
			var packed_scene = trees_packed_scenes.pick_random()
			var scene = packed_scene.instantiate() as ScenePlacer
			entity_tile_map_layer.add_child(scene) 
			var occupies_tiles = scene.get_all_occupied_tiles(entity_tile_map_layer)
			var can_spawn = true
			for occupied_tile in occupies_tiles:
				if not tile_types.has(tile + occupied_tile):
					can_spawn = false
					break
				if tile_types[tile + occupied_tile] == TileType.WATER:
					can_spawn = false
					break
			if can_spawn:
				tile_types[tile] = TileType.TREE
				scene.position = entity_tile_map_layer.map_to_local(tile)
				scene.unpack()
			else:
				scene.queue_free()

	# Place entities
	for tile in tiles:
		if entity_noise.get_noise_2d(tile.x, tile.y) > entity_generation_floor:
			var packed_scene = entity_packed_scenes.pick_random()
			var scene = packed_scene.instantiate() as ScenePlacer
			entity_tile_map_layer.add_child(scene) 
			var occupies_tiles = scene.get_all_occupied_tiles(entity_tile_map_layer)
			var can_spawn = true
			for occupied_tile in occupies_tiles:
				if not tile_types.has(tile + occupied_tile):
					can_spawn = false
					break
				if tile_types[tile + occupied_tile] == TileType.WATER or tile_types[tile + occupied_tile] == TileType.TREE:
					can_spawn = false
					break
			if can_spawn:
				tile_types[tile] = TileType.ENTITY
				scene.position = entity_tile_map_layer.map_to_local(tile)
				scene.unpack()
			else:
				scene.queue_free()

	# Place enemies
	for tile in tiles:
		if enemy_noise.get_noise_2d(tile.x, tile.y) > enemy_generation_floor:
			var packed_scene = enemy_packed_scenes.pick_random()
			var scene = packed_scene.instantiate() as ScenePlacer
			entity_tile_map_layer.add_child(scene) 
			var occupies_tiles = scene.get_all_occupied_tiles(entity_tile_map_layer)
			var can_spawn = true
			for occupied_tile in occupies_tiles:
				if not tile_types.has(tile + occupied_tile):
					can_spawn = false
					break
				if _is_tile_occupied(tile_types, tile + occupied_tile):
					can_spawn = false
					break
			if can_spawn:
				tile_types[tile] = TileType.ENEMIES
				scene.position = entity_tile_map_layer.map_to_local(tile)
				scene.unpack()
			else:
				scene.queue_free()


func _could_tile_be_water(tile):
	var noise_pos = tile
	if noise_pos.x % 2 != 0: noise_pos.x -= 1
	if noise_pos.y % 2 != 0: noise_pos.y -= 1
	if water_noise.get_noise_2d(noise_pos.x, noise_pos.y) > water_generation_floor:
		return true
	return false


func _is_tile_next_to_water(tile: Vector2i):
	if _could_tile_be_water(tile): return false
	if _could_tile_be_water(tile + Vector2i(1,0)): return false
	if _could_tile_be_water(tile + Vector2i(0,1)): return false
	if _could_tile_be_water(tile + Vector2i(-1,0)): return false
	if _could_tile_be_water(tile + Vector2i(0,-1)): return false
	return true

func _is_tile_next_to_water_scaled(tile: Vector2i):
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
	if tile_types[tile] == TileType.TREE : return true
	if tile_types[tile] == TileType.ENTITY : return true
	return false