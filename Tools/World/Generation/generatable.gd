class_name Generatable extends WorldChunkManipulator

enum TileMapLayerType {
	GROUND,
	ENTITIES,
}

enum PlacementType {
	TERRAIN,
	ENTITY,
	TILE_TYPE_ONLY,
	PREMADE,
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

@export var placement_type: PlacementType
@export var tile_type: TileType
@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var can_generate_on_anything: bool = false
@export var can_generate_on_tiles: Array[TileType]
## Frequency for premade scenes, or more advanced noise floor for other generatables
@export var generation_noise_floor: float = .5
@export_group("Premade")
@export var world_chunk_loader : WorldChunkLoader
var premade_world_chunk_datas: Dictionary = {}
var premade_world_size: Vector2i = Vector2i.ZERO
var premade_top_left_corner: Vector2i = Vector2i.ZERO
var unable_to_spawn_on_tiles: Dictionary = {}
var able_to_spawn_on_tiles: Dictionary = {}
@export_group("Tiles and entites")
@export var tile_map_layer_type: TileMapLayerType = TileMapLayerType.GROUND
@export_subgroup("Entities")
@export var scenes: Array[SceneProbabilityPair] = []
@export_subgroup("Tiles")
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

func _ready():
	if placement_type == PlacementType.PREMADE:
		_store_premade_world_data()
		ground_tile_map_layer.queue_free()
		entity_tile_map_layer.queue_free()

func _store_premade_world_data():
	## Get size of world
	var ground_used_rect = ground_tile_map_layer.get_used_rect()
	var start_chunk = tile_to_chunk(ground_used_rect.position)
	var end_chunk = tile_to_chunk(ground_used_rect.end)
	## We want the used tile, not the span inclusive the top left tile
	premade_top_left_corner = ground_used_rect.position
	premade_world_size = ground_used_rect.size

	for chunk_x in range(start_chunk.x, end_chunk.x + 1):
		for chunk_y in range(start_chunk.y, end_chunk.y + 1):
			var chunk = Vector2i(chunk_x, chunk_y)
			premade_world_chunk_datas[chunk] = world_chunk_loader.store_chunk(chunk)
	## Store everything within size
