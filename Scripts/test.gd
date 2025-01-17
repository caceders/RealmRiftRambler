extends Node

@export var tileWorld: WorldChunkHandler
@export var entityWorld: WorldChunkHandler

func _process(delta):
	tileWorld.chunk_load_store()
	entityWorld.chunk_load_store()