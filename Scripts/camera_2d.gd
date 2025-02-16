extends Camera2D

const ZOOM_STEP = Vector2(0.1, 0.1)
const ZOOM_SPEED = 0.5  # Adjust for smoother zoom
const ZOOM_MIN = 1
const ZOOM_MAX = 1.5

const CAMERA_LEAD_LERP_WEIGHT = 0.015

const CAMERA_LEAD_MAX = Vector2(25, 25)

@export var follow: Node2D
@export var debug: bool = false

var _previous_position: Vector2 = Vector2.ZERO
var _camera_lead: Vector2 = Vector2(0, 0)

func _process(delta):

	if follow != null:
		global_position = follow.global_position
		var camera_lead_direction  = Vector2.ZERO
		camera_lead_direction.x = follow.global_position.x - _previous_position.x
		camera_lead_direction.y = follow.global_position.y - _previous_position.y

		camera_lead_direction = camera_lead_direction.normalized()

		_camera_lead = _camera_lead.lerp(CAMERA_LEAD_MAX * camera_lead_direction, CAMERA_LEAD_LERP_WEIGHT)
		global_position = follow.global_position + _camera_lead

		_previous_position = follow.global_position

	if Input.is_action_just_pressed("zoom in"):
		zoom = lerp(zoom, zoom + ZOOM_STEP, ZOOM_SPEED)
		if zoom > Vector2.ONE * ZOOM_MAX and not debug:
			zoom = Vector2.ONE * ZOOM_MAX
	elif Input.is_action_just_pressed("zoom out"):
		zoom = lerp(zoom, zoom - ZOOM_STEP, ZOOM_SPEED)
		if zoom < Vector2.ONE * ZOOM_MIN and not debug:
			zoom = Vector2.ONE * ZOOM_MIN
