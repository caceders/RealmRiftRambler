class_name EntityExitWorldHandler extends Node


@export var world_handler: WorldHandler

func handle_entities_outise_world_border():
	# If entity exist outside loaded chunks - load the relevant chunk and store it now with the entity	
	var all_entities = world_handler.entity_tile_map_layer.get_children()
	var deloaded_chunks_to_update = []
	for entity in all_entities:
		if is_entity_outside_world(entity):
			var chunk = world_handler.position_to_chunk(entity.global_position)
			if chunk not in deloaded_chunks_to_update:
				deloaded_chunks_to_update.append(chunk)
			
	for chunk in deloaded_chunks_to_update:
		world_handler.re_store_chunk(chunk)



func is_entity_outside_world(node: Node2D):
	if world_handler.position_to_chunk(node.global_position) not in world_handler.get_active_chunks():
		return true
	return false
