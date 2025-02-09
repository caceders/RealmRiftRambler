class_name ChaserEvader extends Node2D

const UPDATE_TIME = .5
const MAX_TRIES_FIND_NEW_POSITION = 10

enum BehaviorType{
	CHASE,
	EVADE,
}

@onready var vision: Vision = self.get_parent().get_node("Vision")
@onready var entity: TopDownEntity2D = self.get_parent().get_node("TopDownEntity2D")
@onready var navigation_agent : NavigationAgent2D = self.get_parent().get_node("NavigationAgent2D")


@export var enabled: bool = true
## Chase groups
@export var chase : Array[String] = []
## Evade groups
@export var evade : Array[String] = []

@export var chase_specific : Array[Node2D] = []
@export var evade_specific : Array[Node2D] = []

## If both a group to chase and one to evade is in sight what to prioritize?
@export var prioritize: BehaviorType = BehaviorType.CHASE

var is_reacting: bool = false

var _last_update_time : float = randf_range(0, UPDATE_TIME) #Spread out to gain performance

func _process(delta):

	# Check if its time to look for entitites - performance issues if done on every frame
	if not enabled or Time.get_unix_time_from_system() < _last_update_time + UPDATE_TIME:
		return
	_last_update_time = Time.get_unix_time_from_system()

	is_reacting = false
	var bodies_in_sight = vision.get_bodies_in_sight()
	bodies_in_sight.sort_custom(sort_distance)
	var behavior: BehaviorType
	var react_to_body: Node2D

	for body in bodies_in_sight:
		if prioritize == BehaviorType.CHASE:
			if is_body_chase(body):
				react_to_body = body
				behavior = BehaviorType.CHASE
				break
		if prioritize == BehaviorType.EVADE:
			if is_body_evade(body):
				react_to_body = body
				behavior = BehaviorType.EVADE
				break
	
	if react_to_body == null:
		# Same as above but switched to check for the unprioritized part
		for body in bodies_in_sight:
			if prioritize == BehaviorType.CHASE:
				if is_body_chase(body):
					react_to_body = body
					behavior = BehaviorType.CHASE
					break
			if prioritize == BehaviorType.EVADE:
				if is_body_evade(body):
					react_to_body = body
					behavior = BehaviorType.EVADE
					break

	# If still no body of interest return
	if react_to_body == null:
		return

	# Run away or towards body - ###if no path is found just move as close/far as possible###
	var direction: Vector2
	var distance: float
	if behavior == BehaviorType.CHASE:
		direction = global_position.direction_to(react_to_body.global_position)
		distance = global_position.distance_to(react_to_body.global_position)
		navigation_agent.target_position = global_position + direction * distance
		entity.direction = global_position.direction_to(navigation_agent.get_next_path_position())
		if not navigation_agent.is_target_reachable():
			entity.direction = direction

	elif behavior == BehaviorType.EVADE:
		direction = react_to_body.global_position.direction_to(global_position)
		distance = react_to_body.global_position.distance_to(global_position) + vision.distance
		navigation_agent.target_position = global_position + direction * distance
		entity.direction = global_position.direction_to(navigation_agent.get_next_path_position())
		if not navigation_agent.is_target_reachable():
			entity.direction = direction

	

func is_body_chase(body: Node2D):
	if body in chase_specific:
		return true

	var body_groups = body.get_groups()
	for group in body_groups:
		if group in chase:
			return true
	
	return false

func is_body_evade(body: Node2D):
	if body in evade_specific:
		return true

	var body_groups = body.get_groups()
	for group in body_groups:
		if group in evade:
			return true
	
	return false

func sort_distance(body1: Node2D, body2: Node2D):
	return global_position.distance_squared_to(body1.global_position) > global_position.distance_squared_to(body2.global_position)

func enable():
	enabled = true

func disable():
	enabled = false
	entity.direction = Vector2.ZERO
