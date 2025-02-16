class_name WorldChunkGenerator extends WorldChunkManipulator

var better_terrain_changeset_paint_entity: Dictionary
var better_terrain_changeset_paint_ground: Dictionary

const SEED_OFFSET: int = 518924

@export var generatables_node: Node
@export var world_seed: int = randi()

func _ready():
	var i = 0
	for generatable in generatables_node.get_children():
		generatable.noise_seed = world_seed + i * SEED_OFFSET
		i += 1

func generate_chunk(chunk_coordinate: Vector2i):
	for cell in get_cells_in(chunk_coordinate):
		for generatable in generatables_node.get_children():
			generatable.apply_generatable(cell, self, false, better_terrain_changeset_paint_entity, better_terrain_changeset_paint_ground)

# Remember to remove the extra tile data afterwards!
func generate_extra_tile_data_on_cell_until_generatable_is_found(cell, p_generatable):
	for generatable in generatables_node.get_children():
		if generatable == p_generatable:
			return
		generatable = generatable as Generatable
		generatable.apply_generatable(cell, self, true)
