class_name MapGeneratorHandler extends Node

enum MapType {
	MAP_PLAINS,
}

@export var size: int = 200
@export var map_type: MapType = MapType.MAP_PLAINS

@export var ground_tile_map_layer: WorldChunkLoader
@export var object_tile_map_layer: WorldChunkLoader

@export var center_entity: Node2D
@export var center: Vector2i = Vector2i(0,0)

var map_generator: MapGenerator = MapGenerator.new()

func _ready():
	center = ground_tile_map_layer.position_to_tile(center_entity.global_position)
	clear_world()
	generate()
	ground_tile_map_layer.update_preloaded_chunks()
	object_tile_map_layer.update_preloaded_chunks()
	
	
func generate():
	clear_world()
	match map_type:
		MapType.MAP_PLAINS:	
			map_generator = PlainsMapGenerator.new()
	
	if map_generator != null:
		var map_seed: int = randi()
		map_generator.generate_world(size, object_tile_map_layer, ground_tile_map_layer, map_seed, center)

func clear_world():
	var tile_chunk_folder = DirAccess.open("TileChunks")
	var entity_chunk_folder = DirAccess.open("EntityChunks")
	
	for file in tile_chunk_folder.get_files():
		tile_chunk_folder.remove(file)

	for file in entity_chunk_folder.get_files():
		entity_chunk_folder.remove(file)

	var entities_to_remove = []
	for entity in object_tile_map_layer.get_children():
		if not entity.name == "Player":
			entities_to_remove.append(entity)
			entity.queue_free() 
	
	for entity in entities_to_remove:
		object_tile_map_layer.remove_child(entity)
