extends Node2D

@export var chunkloader: chunkLoader
@export var entity: Node2D
@export var tile_map_layer : TileMapLayer

var _string: String = ""

func save():
	if entity != null:
		_string = chunkloader.serialize_entity(entity)
		entity.queue_free()

func load():
	if entity == null:
		entity = chunkloader.deserialize_entity(_string)
		if entity != null:
			tile_map_layer.add_child(entity)
		
