class_name chunkLoader extends Node

const CHUNK_SIZE = 16

@export var data_store_folder = "ChunkData"
@export var tile_map_layer: TileMapLayer

func serialize_entity(node: Node2D) -> String:
	var packed_scene = node.scene_file_path
	var node_position = node.global_position

	var deload_persistant_data = []
	if node.has_node("DeloadPersistance"):
		var deload_persistance = node.get_node("DeloadPersistance") as DeloadPersistance
		deload_persistant_data = deload_persistance.deload_persistant_data
	
	var entity_data = {}
	entity_data["packed_scene"] = packed_scene
	entity_data["position"] = var_to_str(node_position)
	entity_data["persistant_data"] = var_to_str(deload_persistant_data)
	print(entity_data["persistant_data"])
	var entity_data_string = JSON.stringify(entity_data)
	return entity_data_string

func deserialize_entity(entity_data_string) -> Node2D:
	var json = JSON.new()
	var parse_result = json.parse(entity_data_string)
	if parse_result != OK:
		return null
	
	var entity_data = json.data as Dictionary
	var entity_packed_scene = load(entity_data["packed_scene"]) as PackedScene
	var entity = entity_packed_scene.instantiate()
	entity.global_position = str_to_var(entity_data["position"])
	var persistant_data = str_to_var(entity_data["persistant_data"]) as Array[PersistantData]
	if not persistant_data.is_empty():
		for data in persistant_data:
			var subnode = entity.get_node(data.node_path)
			subnode.set(data.property, data.value)
	return entity
