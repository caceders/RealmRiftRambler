extends NavigationAgent2D

@export var hitbox: CollisionShape2D

func _process(delta):
	var shape = hitbox.shape
	if shape is CapsuleShape2D:
		radius = max(shape.height, shape.radius)
	elif shape is CircleShape2D:
		radius = shape.radius
	elif shape is ConcavePolygonShape2D or shape is ConvexPolygonShape2D:
		var segment_lengths = []
		for segment in shape.segments:
			segment_lengths.append(segment.length)
		radius = max(segment_lengths)
	elif shape is RectangleShape2D:
		radius = max(shape.size.x/2, shape.size.y/2)
	
	return
