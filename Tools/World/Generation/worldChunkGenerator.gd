class_name WorldChunkGenerator extends WorldChunkManipulator

@export var generatables_node: Node

func generate_chunk(chunk_coordinate: Vector2i):
	for cell in get_cells_in(chunk_coordinate):
		for generatable in generatables_node.get_children():
			generatable.apply_generatable(cell, self)

# Remember to remove the extra tile data afterwards!
func generate_extra_tile_data_on_cell_until_generatable_is_found(cell, p_generatable):
	for generatable in generatables_node.get_children():
		if generatable == p_generatable:
			return
		generatable = generatable as Generatable
		generatable.apply_generatable(cell, self, true)
