class_name MapGeneratorHandler extends Node

enum MapType {
	MAP_PLAINS,
}

@export var size: int = 200
@export var map_type: MapType = MapType.MAP_PLAINS

@export var tile_tile_map_layer: WorldChunkLoader
@export var object_tile_map_layer: WorldChunkLoader

@export var tile_chunk_handler: WorldChunkHandler
@export var entity_chunk_handler: WorldChunkHandler

@export var center_entity: Node2D
@export var center: Vector2i = Vector2i(0,0)

var map_generator: MapGenerator = MapGenerator.new()

func _ready():
	center = WorldChunkLoader.position_to_tile(center_entity.global_position)
	clear_world()
	

func _process(delta):
	center = WorldChunkLoader.position_to_tile(center_entity.global_position)
	
func generate():
	clear_world()

	match map_type:
		MapType.MAP_PLAINS:	
			map_generator = PlainsMapGenerator.new()
	
	if map_generator != null:
		var map_seed: int = randi()
		map_generator.generate_world(size, object_tile_map_layer, tile_tile_map_layer, map_seed, center)

		store_world()

func store_world():

	var chunks_to_store = WorldChunkLoader.get_chunks_in(center + Vector2i(size, size), center + Vector2i(-size, -size))
	for chunk in chunks_to_store:
		tile_chunk_handler.chunks_to_store.append(chunk)
		entity_chunk_handler.chunks_to_store.append(chunk)
	
	tile_chunk_handler.store_chunks()
	entity_chunk_handler.store_chunks()

	tile_chunk_handler.load_and_generate_chunks()
	entity_chunk_handler.load_and_generate_chunks()

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
