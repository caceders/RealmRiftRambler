class_name EntityExitWorldHandler extends Node

const UPDATE_TIME_INTERVAL = .2

@export var world_chunk_handler: WorldChunkHandler
@onready var world_chunk_loader: WorldChunkLoader = world_chunk_handler.world_chunk_loader

var _last_update_time = 0
func _process(_delta):
	if _last_update_time < Time.get_unix_time_from_system() + UPDATE_TIME_INTERVAL:
		_last_update_time = Time.get_unix_time_from_system()

		# If entity exist outside loaded chunks - load the relevant chunk and store it now with the entity	
		var all_entities = world_chunk_loader.get_children()
		var deloaded_chunks_to_update = []
		for entity in all_entities:
			if is_entity_outside_world(entity):
				var chunk = WorldChunkLoader.position_to_chunk(entity.global_position)
				if chunk not in deloaded_chunks_to_update:
					deloaded_chunks_to_update.append(chunk)
				
		for chunk in deloaded_chunks_to_update:
			world_chunk_loader._load_chunk(chunk)
			world_chunk_loader._store_chunk(chunk)



func is_entity_outside_world(node: Node2D):
	if WorldChunkLoader.position_to_chunk(node.global_position) not in world_chunk_handler.get_loaded_chunks():
		return true
	return false
