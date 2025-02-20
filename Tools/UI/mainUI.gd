extends Control

@export var map_ui: MapUI
@export var ground_tile_map_layer: TileMapLayerWithTileData

# Called when the node enters the scene tree for the first time.
func _ready():
	map_ui.ground_tile_map_layer = ground_tile_map_layer
