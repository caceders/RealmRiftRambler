class_name WorldChunkGenerator extends WorldChunkManipulator

enum TileType {
	GROUND,
	WATER,
	GRASS,
	DIRT,
	FLOWER,
	STANDING_STONE,
	FOREST,
	ENTITY,
}
@export var noise_test: FastNoiseLite = FastNoiseLite.new()
@export_group("Water")
@export var water_noise: FastNoiseLite = FastNoiseLite.new()
@export var water_generation_floor: float = .5

@export_group("Grass")
@export var grass_noise: FastNoiseLite = FastNoiseLite.new()
@export var grass_generation_floor: float = 0

@export_group("Dirt")
@export var dirt_noise: FastNoiseLite = FastNoiseLite.new()
@export var dirt_generation_floor: float = 0

@export_group("Flower")
@export var flower_noise: FastNoiseLite = FastNoiseLite.new()
@export var flower_generation_floor: float = 0

@export_group("Standing stones")
@export var standing_stone_noise: FastNoiseLite = FastNoiseLite.new()
@export var standing_stone_generation_floor: float = 0
@export var standing_stone_packed_scenes: Array[PackedScene] = []

@export_group("Buildings")
@export var building_noise: FastNoiseLite = FastNoiseLite.new()
@export var building_generation_floor: float = 0
@export var building_packed_scenes: Array[PackedScene] = []

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

		if grass_noise.get_noise_2d(noise_pos.x, noise_pos.y) > grass_generation_floor and _could_tile_be_water_scaled(tile):
			BetterTerrain.set_cell(ground_tile_map_layer, tile, TileType.GRASS)
			tile_types[tile] = TileType.GRASS
	
	# Place roads
	for tile in tiles:
		# make 4 by 4 tiles have dirt together to match with tileset
		var noise_pos = tile
		if noise_pos.x % 2 != 0: noise_pos.x -= 1
		if noise_pos.y % 2 != 0: noise_pos.y -= 1

		if dirt_noise.get_noise_2d(noise_pos.x, noise_pos.y) > dirt_generation_floor and _could_tile_be_water_scaled(tile):
			BetterTerrain.set_cell(ground_tile_map_layer, tile, TileType.DIRT)
			tile_types[tile] = TileType.DIRT
	
	# Place flowers
	for tile in tiles:
		var noise_pos = tile

		if flower_noise.get_noise_2d(noise_pos.x, noise_pos.y) > flower_generation_floor and not _could_tile_be_water(tile):
			if tile_types[tile] != TileType.DIRT:
				BetterTerrain.set_cell(entity_tile_map_layer, tile, TileType.FLOWER)
				tile_types[tile] = TileType.FLOWER
	
	# Place standing stones
	for tile in tiles:
		var noise_pos = tile

		if standing_stone_noise.get_noise_2d(noise_pos.x, noise_pos.y) > standing_stone_generation_floor and not _could_tile_be_water(tile):
			if tile_types[tile] != TileType.DIRT:
				_place_entity(tile, standing_stone_packed_scenes, tile_types)

	# Place buildings
	for tile in tiles:
		var noise_pos = tile

		if building_noise.get_noise_2d(noise_pos.x, noise_pos.y) > building_generation_floor and not _could_tile_be_water(tile):
			if tile_types[tile] != TileType.DIRT:
				_place_entity(tile, building_packed_scenes, tile_types)

	# Place forest
	for tile in tiles:
		if forest_noise.get_noise_2d(tile.x, tile.y) > forest_generation_floor:
			if _could_tile_be_water(tile) or tile_types[tile] == TileType.DIRT: continue
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
	var occupies_tiles = null
	if scene is ScenePlacer:
		occupies_tiles = scene.get_all_occupied_tiles(entity_tile_map_layer)
	else:
		occupies_tiles = get_all_occupied_tiles(scene)
	var can_spawn = true
	for occupied_tile in occupies_tiles:
		if tile_types.has(tile + occupied_tile):
			if tile_types[tile + occupied_tile] == TileType.ENTITY or tile_types[tile] == TileType.DIRT:
				can_spawn = false
				break

		if _could_tile_be_water(tile + occupied_tile):
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

func _could_tile_be_water_scaled(tile: Vector2i):
	if tile.x % 2 != 0: tile.x -= 1
	if tile.y % 2 != 0: tile.y -= 1
	if _could_tile_be_water(tile + Vector2i(0,0)): return false
	if _could_tile_be_water(tile + Vector2i(0,-1)): return false
	if _could_tile_be_water(tile + Vector2i(-1,0)): return false
	if _could_tile_be_water(tile + Vector2i(-1,-1)): return false



	return true

func _is_tile_occupied(tile_types: Dictionary, tile:Vector2i):
	if tile_types[tile] == TileType.WATER : return true
	if tile_types[tile] == TileType.ENTITY : return true
	return false

func get_all_occupied_tiles(entity: Node2D) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	if not entity.has_node("HitBox"):
		return []
	var hitbox = entity.get_node("HitBox") as HitBox
	var top_left = (entity.global_position - hitbox.circle_shape.radius*Vector2.ONE/2)
	var bottom_right = (entity.global_position + hitbox.circle_shape.radius*Vector2.ONE/2)
	# var color_rect = ColorRect.new()
	# color_rect.color = Color.RED
	# color_rect.position = - hitbox.circle_shape.radius*Vector2.ONE/2
	# color_rect.size = hitbox.circle_shape.radius*Vector2.ONE
	# child.add_child(color_rect)  # Add the ColorRect to the scene
	var start_tile = entity_tile_map_layer.local_to_map(top_left)
	var end_tile = entity_tile_map_layer.local_to_map(bottom_right)
	for x in range(start_tile.x, end_tile.x + 1):
		for y in range(start_tile.y, end_tile.y + 1):
			tiles.append(Vector2i(x,y))
		
	
	return tiles