class_name Generatable extends Node

enum TileMapLayerType {
	GROUND,
	ENTITIES,
}

enum PlacementType {
	TERRAIN,
	ENTITY,
	TILE_TYPE_ONLY,
}

enum TileType {
	GROUND,
	WATER,
	GRASS,
	DIRT,
	FLOWER,
	## Non-terrains
	STANDING_STONE,
	FOREST,
	ENTITY,
}
@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var generation_noise_floor: float = .5
@export var tile_type: TileType
@export var tile_map_layer_type: TileMapLayerType = TileMapLayerType.GROUND
@export var placement_type: PlacementType
@export var can_generate_on_anything: bool = false
@export var can_generate_on_tiles: Array[TileType]
@export var scenes: Array[SceneProbabilityPair] = []
@export var is_4x4: bool = false

func pick_random_scene_weighted() -> PackedScene:
	var total_weights = 0
	for scene_probability_pair in scenes:
		total_weights += scene_probability_pair.weight
	var random_point_in_total_weights = randf_range(0, total_weights)
	var current_weight_top = 0
	for scene_probability_pair in scenes:
		current_weight_top += scene_probability_pair.weight
		if random_point_in_total_weights < current_weight_top:
			return scene_probability_pair.scene
	return null