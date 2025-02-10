class_name ScenePlacer extends Node2D

func unpack():
	var children = get_children()
	var parent = get_parent()
	for child in children:
		child.reparent(parent)
	self.queue_free()

func get_all_occupied_tiles(tile_map_layer: TileMapLayer) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	var children = get_children()
	for child in children:
		if not child.has_node("HitBox"):
			continue
		var hitbox = child.get_node("HitBox") as HitBox
		var top_left = (child.global_position - hitbox.circle_shape.radius*Vector2.ONE/2)
		var bottom_right = (child.global_position + hitbox.circle_shape.radius*Vector2.ONE/2)
		# var color_rect = ColorRect.new()
		# color_rect.color = Color.RED
		# color_rect.position = - hitbox.circle_shape.radius*Vector2.ONE/2
		# color_rect.size = hitbox.circle_shape.radius*Vector2.ONE
		# child.add_child(color_rect)  # Add the ColorRect to the scene
		var start_tile = tile_map_layer.local_to_map(top_left)
		var end_tile = tile_map_layer.local_to_map(bottom_right)
		for x in range(start_tile.x, end_tile.x + 1):
			for y in range(start_tile.y, end_tile.y + 1):
				tiles.append(Vector2i(x,y))
		
	
	return tiles

func _process(_delta):
	unpack()