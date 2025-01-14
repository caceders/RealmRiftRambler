extends Node

@export var world_heigth: int = 100
@export var world_width: int = 100
@export var noise: FastNoiseLite

@export var water_grass_edge: float = 0.3

@onready var base_tile_layer = $Base as TileMapLayer
@onready var objects_tile_layer = $Objects as TileMapLayer



func generate_world():
	noise.seed = randi()
	# Grass
	base_tile_layer.clear()
	print("Generating world")
	
	var x_coord_begin: int = - round(float(world_width) / 2)
	var x_coord_end: int = round(float(world_width) / 2)
	var y_coord_begin: int = - round(float(world_heigth) / 2)
	var y_coord_end: int = round(float(world_heigth) / 2)
	
	var grass_terrain_coords = []
	for x in range(x_coord_begin, x_coord_end):
		for y in range(y_coord_begin, y_coord_end):
			if noise.get_noise_2d(x, y) >= water_grass_edge:
				base_tile_layer.set_cell(Vector2(x,y), 0, Vector2(61,8))
				grass_terrain_coords.append(Vector2(x,y))
	
	
	# Water
	var water_terrain_coords = []
	for x in range(x_coord_begin, x_coord_end):
		for y in range(y_coord_begin, y_coord_end):
			if noise.get_noise_2d(x, y) < water_grass_edge:
				base_tile_layer.set_cell(Vector2(x,y), 0, Vector2(26,4))
				water_terrain_coords.append(Vector2(x,y))
	


	# Objects
	objects_tile_layer.clear()
	for x in range(x_coord_begin, x_coord_end):
		for y in range(y_coord_begin, y_coord_end):
			if randf_range(0, 100) > 99 and noise.get_noise_2d(x, y) >= water_grass_edge:
				objects_tile_layer.set_cell(Vector2(x,y), 1, Vector2(0,0), 2)
	

	# Set terrain at end. If set earlier everything goes to shit
	base_tile_layer.set_cells_terrain_connect(grass_terrain_coords, 0, 1)
	base_tile_layer.set_cells_terrain_connect(water_terrain_coords, 0, 2)