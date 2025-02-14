class_name PremadeGeneratable extends Generatable

# Is the world position forced
@export var is_forced_placement: bool = false
@export var forced_placement_top_left_corner: Vector2i = Vector2i(0, 0)
# If the premade is placed only once
@export var is_one_off : bool = false
# World chunk loader to store the premade world
@export var world_chunk_loader : WorldChunkLoader

@export var premade_ground_tile_map_layer: TileMapLayerWithTileData
@export var premade_entity_tile_map_layer: TileMapLayerWithTileData

var _is_placed: bool = false
var _cells_in_first_placement: Dictionary = {}
var _premade_world_chunk_datas: Dictionary = {}
var _premade_world_size: Vector2i = Vector2i.ONE
var _premade_top_left_corner: Vector2i = Vector2i.ZERO

# For speeding up calculations of wether the premade is able to spawn at a position between chunks
var _unable_to_spawn_on_cells: Dictionary = {}
var _able_to_spawn_on_cells: Dictionary = {}

func _ready():
	_store_premade_world_data()
	premade_ground_tile_map_layer.queue_free()
	premade_entity_tile_map_layer.queue_free()

func _store_premade_world_data():
	# Get size of world
	var ground_used_rect = premade_ground_tile_map_layer.get_used_rect()
	var start_chunk = cell_to_chunk(ground_used_rect.position)
	var end_chunk = cell_to_chunk(ground_used_rect.end)
	_premade_top_left_corner = ground_used_rect.position
	_premade_world_size = ground_used_rect.size
	# Needed to avoid integer division by 0 which causes windows to crash.
	if _premade_world_size == Vector2i.ZERO:
		_premade_world_size = Vector2i.ONE

	for chunk_x in range(start_chunk.x, end_chunk.x + 1):
		for chunk_y in range(start_chunk.y, end_chunk.y + 1):
			var chunk = Vector2i(chunk_x, chunk_y)
			_premade_world_chunk_datas[chunk] = world_chunk_loader.store_chunk(chunk)

func apply_generatable(cell: Vector2i, world_chunk_generator: WorldChunkGenerator, only_update_extra_info: bool = false):
	## TODO: REPAIR HERE
	var length_of_premades_to_cell_floored: Vector2i = floor(cell/_premade_world_size)
	var premade_world_tile_offset_in_relation_to_total_size_x = fposmod(cell.x, _premade_world_size.x)
	var premade_world_tile_offset_in_relation_to_total_size_y = fposmod(cell.y, _premade_world_size.y)
	# We map the whole premade world dimension to one cell in the noise map
	var noise_pos: Vector2i = length_of_premades_to_cell_floored
	var world_top_left_cell: Vector2i = length_of_premades_to_cell_floored * _premade_world_size

	if noise.get_noise_2d(noise_pos.x, noise_pos.y) < generation_noise_floor and not is_forced_placement:
		return

	elif not _can_generate(cell, world_chunk_generator, world_top_left_cell):
		## Update precalculations
		if not _unable_to_spawn_on_cells.has(cell):
			for cell_x in range(world_top_left_cell.x, world_top_left_cell.x + _premade_world_size.x):
				for cell_y in range(world_top_left_cell.y, world_top_left_cell.y + _premade_world_size.y):
					var add_cell = Vector2i(cell_x, cell_y)
					_unable_to_spawn_on_cells[add_cell] = "nah"
		return
	
	else:
		if not _able_to_spawn_on_cells.has(cell):
			for cell_x in range(world_top_left_cell.x, world_top_left_cell.x + _premade_world_size.x):
				for cell_y in range(world_top_left_cell.y, world_top_left_cell.y + _premade_world_size.y):
					var add_cell = Vector2i(cell_x, cell_y)
					_able_to_spawn_on_cells[add_cell] = "yah"
	
	_is_placed = true
	var tile_in_premade_x = _premade_top_left_corner.x + premade_world_tile_offset_in_relation_to_total_size_x
	var tile_in_premade_y = _premade_top_left_corner.y + premade_world_tile_offset_in_relation_to_total_size_y

	# If generatable is forced placement, place from the given top left corner
	if is_forced_placement:
		tile_in_premade_x = _premade_top_left_corner.x + (cell.x - forced_placement_top_left_corner.x)
		tile_in_premade_y = _premade_top_left_corner.y + (cell.y - forced_placement_top_left_corner.y)


	var tile_in_premade: Vector2i = Vector2i(tile_in_premade_x, tile_in_premade_y)
	var premade_chunk = cell_to_chunk(Vector2i(tile_in_premade_x, tile_in_premade_y))
	var premade_chunk_data = _premade_world_chunk_datas[premade_chunk]

	# Load ground tiles	
	for tile_data in premade_chunk_data["ground_tiles"]:
		if tile_data["coordinate"] == tile_in_premade and not only_update_extra_info:
			BetterTerrain.set_cell(ground_tile_map_layer, cell, tile_data["terrain_id"])
	
	# Load entity tiles
	for tile_data in premade_chunk_data["entity_tiles"]:
		if tile_data["coordinate"] == tile_in_premade and not only_update_extra_info:
			BetterTerrain.set_cell(entity_tile_map_layer, cell, tile_data["terrain_id"])
	
	# Load entities
	for entity_data in premade_chunk_data["entities"]:
		if position_to_cell(entity_data["position"]) == tile_in_premade and not only_update_extra_info:
			var entity_packed_scene = load(entity_data["packed_scene"]) as PackedScene
			if entity_packed_scene == null:
				continue
			var entity = entity_packed_scene.instantiate()
			# Move the position to the position in local world coordinates
			entity.global_position = entity_data["position"] - (tile_in_premade as Vector2) * CELL_SIZE_PIXELS + (cell as Vector2) * CELL_SIZE_PIXELS
			var persistant_data = entity_data["persistant_data"] as Array[PersistantData]
			if not persistant_data.is_empty():
				for data in persistant_data:
					var subnode = entity.get_node(data.node_path)
					subnode.set(data.property, data.value)
			entity_tile_map_layer.add_child(entity)
	
	# Update first_placement info
	if _cells_in_first_placement.is_empty():
		for cell_x in range(world_top_left_cell.x, world_top_left_cell.x + _premade_world_size.x):
			for cell_y in range(world_top_left_cell.y, world_top_left_cell.y + _premade_world_size.y):
				var add_cell = Vector2i(cell_x, cell_y)
				_cells_in_first_placement[add_cell] = "yah"
	
	apply_new_extra_tile_data(cell)

		
func _can_generate(cell, world_chunk_generator, world_top_left_cell):
	if is_one_off and _is_placed and not _cells_in_first_placement.has(cell):
		return false
	
	if is_forced_placement:
		if cell.x < _premade_top_left_corner.x or cell.x > _premade_top_left_corner.x + _premade_world_size.x:
			return false
		elif cell.y < _premade_top_left_corner.y or cell.y > _premade_top_left_corner.y + _premade_world_size.y:
			return false
		return true

	if _able_to_spawn_on_cells.has(cell): ## We've made the calculations for this tile before. We can conclude early that we CAN spawn
		return true

	if _unable_to_spawn_on_cells.has(cell): ## We've made the calculations for this tile before. We can conclude early that we CANT spawn
		return false

	for cell_x in range(world_top_left_cell.x, world_top_left_cell.x + _premade_world_size.x):
		for cell_y in range(world_top_left_cell.y, world_top_left_cell.y + _premade_world_size.y):
			var check_cell = Vector2i(cell_x, cell_y)
			if not _can_generate_on_cell(check_cell, world_chunk_generator):
				return false
	return true
