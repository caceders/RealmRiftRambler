class_name TileMapLayerWithTileData extends TileMapLayer

var _extra_tile_data: Dictionary = {}

func get_extra_data(tile_coordinate: Vector2i):
	if _extra_tile_data.has(tile_coordinate):
		return _extra_tile_data[tile_coordinate]
	else:
		return null
	
func set_extra_data(tile_coordinate: Vector2i, extra_tile_data: ExtraTileData):
	_extra_tile_data[tile_coordinate] = extra_tile_data

func remove_extra_data(tile_coordinate: Vector2i):
	_extra_tile_data.erase(tile_coordinate)