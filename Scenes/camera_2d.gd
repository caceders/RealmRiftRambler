extends Camera2D

const ZOOM_STEP = Vector2(0.1, 0.1)
const ZOOM_SPEED = 0.5  # Adjust for smoother zoom

@export var follow: Node2D

func _process(delta):

	if follow != null:
		position = position.lerp(follow.position, .1)

	if Input.is_action_just_pressed("zoom in"):
		zoom = lerp(zoom, zoom + ZOOM_STEP, ZOOM_SPEED)
	elif Input.is_action_just_pressed("zoom out"):
		zoom = lerp(zoom, zoom - ZOOM_STEP, ZOOM_SPEED)
