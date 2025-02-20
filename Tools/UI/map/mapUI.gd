class_name MapUI extends Control

const MINIMAP_SIZE_SMALL = 120 * Vector2.ONE
const MINIMAP_SIZE_MEDIUM = 160 * Vector2.ONE
const MINIMAP_SIZE_BIG = 200 * Vector2.ONE

const FULLSCREEN_SIZE = Vector2(1152 - 300, 648 - 300)

const UPDATE_FRAMES = 64

## How many tiles in the world tilemap corresponds to one tile in the map
@export var unit_tile_size = 4
@export var sub_viewport: SubViewport
@export var _map_tile_map_layer: TileMapLayer
@export var ground_tile_map_layer: TileMapLayerWithTileData

# How far out from the center should the map load (It only add	s the actual loaded world to map!)
@export var map_render_distance_units: int = 10
@export var map_zoom = .1
var map_size: Vector2 = MINIMAP_SIZE_BIG
var map_tile_map_layer_position:
	get:
		return map_size/2

var size_difference: Vector2:
	get:
		return (get_viewport().size as Vector2)/map_size

var _changeset = null
var _changeset_paint: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_better_terrain_changeset()
	sub_viewport.size = map_size
	_map_tile_map_layer.scale = Vector2.ONE * size_difference * map_zoom
	_map_tile_map_layer.position = (map_tile_map_layer_position - ((get_map_offset() as Vector2)) * size_difference * map_zoom / 2)
	if Engine.get_frames_drawn() % UPDATE_FRAMES == 0:
		update_map_info()

func get_most_common_environment_in_unit(coordinate: Vector2i):
	var tiles = get_tiles_in_unit(coordinate)
	var tile_dict = {}
	for tile in tiles:
		var extra_data = ground_tile_map_layer.get_extra_data(tile) as ExtraTileData
		if extra_data == null:
			continue
		var environment = extra_data.environment
		if tile_dict.has(environment):
			tile_dict[environment] += 1
		else:
			tile_dict[environment] = 1
	
	var most_common_environment = tile_dict.keys().reduce(func(a, b): return a if tile_dict[a] > tile_dict[b] else b)
	return most_common_environment

func get_most_common_feature_that_is_not_none_in_unit(coordinate: Vector2i):
	var tiles = get_tiles_in_unit(coordinate)
	var tile_dict = {}
	for tile in tiles:
		var extra_data = ground_tile_map_layer.get_extra_data(tile) as ExtraTileData
		if extra_data == null:
			continue
		var feature = extra_data.feature
		if feature == ExtraTileData.FEATURE.NONE:
			continue
		if tile_dict.has(feature):
			tile_dict[feature] += 1
		else:
			tile_dict[feature] = 1
	
	var most_common_feature = tile_dict.keys().reduce(func(a, b): return a if tile_dict[a] > tile_dict[b] else b)
	return most_common_feature

func update_map_info():
	var units = get_units_in_view()
	for unit in units:
		var environment = get_most_common_environment_in_unit(unit)
		var feature = get_most_common_feature_that_is_not_none_in_unit(unit)
		if feature != null:
			match feature:
				ExtraTileData.FEATURE.SPECIAL:
					_changeset_paint[unit] = 3
					continue
				ExtraTileData.FEATURE.ROAD:
					_changeset_paint[unit] = 4
					continue

		

		match environment:
			ExtraTileData.ENVIRONMENT.SPECIAL:
				_changeset_paint[unit] = 3
			ExtraTileData.ENVIRONMENT.PLAINS:
				_changeset_paint[unit] = 1
			ExtraTileData.ENVIRONMENT.FOREST:
				_changeset_paint[unit] = 2
			ExtraTileData.ENVIRONMENT.POND:
				_changeset_paint[unit] = 0
			_:
				continue
		
	BetterTerrain.update_terrain_cells(_map_tile_map_layer, units)

func update_better_terrain_changeset():
	if _changeset == null:
		_changeset = BetterTerrain.create_terrain_changeset(_map_tile_map_layer, _changeset_paint)
	
	if BetterTerrain.is_terrain_changeset_ready(_changeset):
		BetterTerrain.apply_terrain_changeset(_changeset)
		_changeset = BetterTerrain.create_terrain_changeset(_map_tile_map_layer, _changeset_paint)
		_changeset_paint = {}

func get_units_in_view():
	var units: Array[Vector2i] = []
	var center_unit = get_center_unit() as Vector2i
	var start_unit = center_unit - Vector2i.ONE * map_render_distance_units
	var end_unit = center_unit + Vector2i.ONE * map_render_distance_units
	for x in range(start_unit.x, end_unit.x + 1):
		for y in range(start_unit.y, end_unit.y + 1):
			units.append(Vector2i(x, y))
	return units

func get_tiles_in_unit(position: Vector2i):
	var tiles: Array[Vector2i] = []
	var start_x = position.x * unit_tile_size
	var start_y = position.y * unit_tile_size
	for x in range(start_x, start_x + unit_tile_size + 1):
		for y in range(start_y, start_y + unit_tile_size + 1):
			tiles.append(Vector2i(x,y))
	
	return tiles

func get_center_unit() -> Vector2i:
	var center = Player.player_position as Vector2
	var center_unit = (center / (unit_tile_size * WorldChunkManipulator.CELL_SIZE_PIXELS)).floor() as Vector2i
	return center_unit

func get_map_offset() -> Vector2i:
	var center = Player.player_position as Vector2
	var center_unit = (center / (unit_tile_size)).floor() as Vector2i
	return center_unit
