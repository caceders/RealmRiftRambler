class_name Strafer extends Node2D

const MAX_TRIES_FOR_NEW_AREA = 3
const CHECK_FOR_STUCK_TIME_MS = 1000
const CONSIDER_STUCK_DISTANCE_CHANGE = 20

enum StrafeState{
	IDLE,
	WALKING,
}

enum StrafeCentrumType{
	ENTITY_POSITION,
	SET_POSITION,
	SPAWN_POSITION,
	OTHER_NODE,
}

@onready var navigation_agent : NavigationAgent2D = self.get_parent().get_node("NavigationAgent2D")
@onready var entity: TopDownEntity2D = self.get_parent().get_node("TopDownEntity2D")

@export var enabled: bool = true

@export var strafe_centrum_type: StrafeCentrumType = StrafeCentrumType.SPAWN_POSITION

@export var min_stand_still_time: float = 1
@export var max_stand_still_time: float = 5

@export var min_strafe_distance: float = 10
@export var max_strafe_distance: float = 50

@export var other_node: Node2D
@export var strafe_weight: Vector2 = Vector2(0, 0)
@export var set_strafe_centrum_position: Vector2 = Vector2(0, 0)

var _strafe_centrum_position: Vector2 = Vector2(0, 0)

var _active_state: StrafeState = StrafeState.IDLE
var _stand_still_timer : Timer
var _has_sat_spawn_pos: bool = false

var _last_position: Vector2 = Vector2(0,0)
var _last_position_set_time_ms: float = 0

func _ready():
	_stand_still_timer = Timer.new()
	_stand_still_timer.one_shot = true
	add_child(_stand_still_timer)


func _process(_delta):
	if not _has_sat_spawn_pos:
		_has_sat_spawn_pos = true
		_strafe_centrum_position = global_position
	if not enabled:
		return
	match strafe_centrum_type:
		StrafeCentrumType.ENTITY_POSITION:
			_strafe_centrum_position = global_position
		StrafeCentrumType.SET_POSITION:
			_strafe_centrum_position = set_strafe_centrum_position
		StrafeCentrumType.OTHER_NODE:
			if other_node != null:
				_strafe_centrum_position = other_node.global_position

	match _active_state:
		StrafeState.IDLE:
			if _stand_still_timer.time_left == 0:
				_enter_state(StrafeState.WALKING)
				return
			return

		StrafeState.WALKING:
			# Check if stuck:
			if Time.get_ticks_msec() > CHECK_FOR_STUCK_TIME_MS + _last_position_set_time_ms:
				_last_position_set_time_ms = Time.get_ticks_msec()
				if global_position.distance_squared_to(_last_position) < CONSIDER_STUCK_DISTANCE_CHANGE:
					_enter_state(StrafeState.IDLE)
				else:
					_last_position = global_position
			
			# Check if target is reached
			if navigation_agent.is_target_reached():
				_enter_state(StrafeState.IDLE)
				return
			entity.direction = global_position.direction_to(navigation_agent.get_next_path_position())


func _enter_state(state: StrafeState):
	if not enabled:
		return
	_active_state = state
	match _active_state:
		StrafeState.IDLE:
			entity.direction = Vector2(0,0)
			_stand_still_timer.start(randf_range(min_stand_still_time, max_stand_still_time))
			return
		StrafeState.WALKING:
			var tries = 1
			_last_position = entity.global_position
			_last_position_set_time_ms = Time.get_ticks_msec()
			while true:
				var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
				var distance = randf_range(min_strafe_distance, max_strafe_distance)
				navigation_agent.target_position = _strafe_centrum_position + (direction * distance) + strafe_weight
				tries += 1
				if navigation_agent.is_target_reachable():
					return
				if tries >= MAX_TRIES_FOR_NEW_AREA:
					_enter_state(StrafeState.IDLE)
					return
				

func enable():
	enabled = true
	_stand_still_timer.start(randf_range(min_stand_still_time, max_stand_still_time))

func disable():
	enabled = false
	entity.direction = Vector2.ZERO
