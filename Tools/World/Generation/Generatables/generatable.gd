class_name Generatable extends WorldChunkManipulator

@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var extra_tile_data: ExtraTileData = ExtraTileData.new()
## Wether or not the generatable should place a tile or an entity, or just place info about the tile. Like updating a tile to belong to the forest environment
@export var only_extra_info: bool = false

@export var can_generate_over_all_biomes: bool = false
@export var can_generate_over_biome: Array[ExtraTileData.BIOME]

@export var can_generate_over_all_environments: bool = false
@export var can_generate_over_environment: Array[ExtraTileData.ENVIRONMENT]

@export var can_generate_over_all_features: bool = false
@export var can_generate_over_feature: Array[ExtraTileData.FEATURE]

@export var can_generate_over_all_objects: bool = false
@export var can_generate_over_object: Array[ExtraTileData.OBJECT]


@export var noise_seed = 0:
	get:
		return noise.seed
	set(value):
		noise.seed = value
		
@export var generation_noise_floor: float = .5

func apply_generatable(_cell: Vector2i, _world_chunk_generator: WorldChunkGenerator, _only_update_extra_info: bool = false):
	pass

func apply_new_extra_tile_data(cell):
	var placed_tile_extra_tile_data = ground_tile_map_layer.get_extra_data(cell)
	
	if placed_tile_extra_tile_data == null:
		placed_tile_extra_tile_data = ExtraTileData.new()

	if extra_tile_data.biome != ExtraTileData.BIOME.NONE:
		placed_tile_extra_tile_data.biome = extra_tile_data.biome
	if extra_tile_data.environment != ExtraTileData.ENVIRONMENT.NONE:
		placed_tile_extra_tile_data.environment = extra_tile_data.environment
	if extra_tile_data.feature != ExtraTileData.FEATURE.NONE:
		placed_tile_extra_tile_data.feature = extra_tile_data.feature
	if extra_tile_data.object != ExtraTileData.OBJECT.NONE:
		placed_tile_extra_tile_data.object = extra_tile_data.object
	
	ground_tile_map_layer.set_extra_data(cell, placed_tile_extra_tile_data)

func _can_generate_on_cell(cell: Vector2i, world_chunk_generator: WorldChunkGenerator):
	var placed_tile_extra_tile_data = ground_tile_map_layer.get_extra_data(cell)
	if placed_tile_extra_tile_data == null:
		world_chunk_generator.generate_extra_tile_data_on_cell_until_generatable_is_found(cell, self)
		placed_tile_extra_tile_data = ground_tile_map_layer.get_extra_data(cell)
		ground_tile_map_layer.remove_extra_data(cell)
	
	if placed_tile_extra_tile_data == null:
		# If still null it means this is the first generatable
		return true

	if not can_generate_over_all_biomes:
		if not placed_tile_extra_tile_data.biome == ExtraTileData.BIOME.NONE:
			if not placed_tile_extra_tile_data.biome in can_generate_over_biome:
				return false

	if not can_generate_over_all_environments:
		if not placed_tile_extra_tile_data.environment == ExtraTileData.ENVIRONMENT.NONE:
			if not placed_tile_extra_tile_data.environment in can_generate_over_environment:
				return false
				
	if not can_generate_over_all_features:
		if  not placed_tile_extra_tile_data.feature == ExtraTileData.FEATURE.NONE:
			if not placed_tile_extra_tile_data.feature in can_generate_over_feature:
				return false

	if not can_generate_over_all_objects:
		if not placed_tile_extra_tile_data.object == ExtraTileData.OBJECT.NONE:
			if not placed_tile_extra_tile_data.object in can_generate_over_object:
				return false

	return true
