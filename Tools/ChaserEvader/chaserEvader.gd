class_name ChaserEvader extends Node2D

const TEST_DISTANCE_INTERVAL = 10
const UPDATE_TIME = 1
const MAX_TRIES_FIND_NEW_POSITION = 10

enum BehaviorType{
	CHASE,
	EVADE,
}

@export var vision: Vision
@export var entity: TopDownEntity2D
@export var enabled: bool = true
@export var navigation_agent : NavigationAgent2D
## Chase groups
@export var chase : Array[String] = []
## Evade groups
@export var evade : Array[String] = []

@export var chase_specific : Array[Node2D] = []
@export var evade_specific : Array[Node2D] = []

## If both a group to chase and one to evade is in sight what to prioritize?
@export var prioritize: BehaviorType = BehaviorType.CHASE

var _behavior : BehaviorType = BehaviorType.CHASE
var _body_to_react_to : Node2D
var _last_update_time : float = randf_range(0, UPDATE_TIME) #Spread out to gain performance

func _ready():
	vision.body_entered_sight.connect(_on_body_entered_vision)
	vision.body_exited_sight.connect(_on_body_exited_vision)

func _physics_process(delta):
	if not enabled:
		return
		
	if _body_to_react_to == null:
		return
		
	if _body_to_react_to.global_position.distance_to(global_position) > vision.distance:
		entity.direction = Vector2.ZERO
	
	if enabled and _body_to_react_to:
		if Time.get_unix_time_from_system() > _last_update_time + UPDATE_TIME:
			_last_update_time = Time.get_unix_time_from_system()
			if _behavior == BehaviorType.EVADE:
				# Run away until body is out of sight - or as far as possible
				var distance_reduction = 0
				var direction = _body_to_react_to.global_position.direction_to(global_position)
				var distance = _body_to_react_to.global_position.distance_to(global_position) + vision.distance - distance_reduction
				navigation_agent.target_position = global_position + direction * distance
				var tries = 0
				while not navigation_agent.is_target_reachable():
					distance_reduction += TEST_DISTANCE_INTERVAL
					direction = _body_to_react_to.global_position.direction_to(global_position)
					distance = _body_to_react_to.global_position.distance_to(global_position) + vision.distance - distance_reduction
					navigation_agent.target_position = global_position + direction * distance
					tries += 1
					if tries > MAX_TRIES_FIND_NEW_POSITION:
						break
				

			elif _behavior == BehaviorType.CHASE:
				# Run to body - or as near as possible
				var distance_reduction = 0
				var direction = global_position.direction_to(_body_to_react_to.global_position)
				var distance = global_position.distance_to(_body_to_react_to.global_position) - distance_reduction
				navigation_agent.target_position = global_position + direction * distance
				var tries = 0
				while not navigation_agent.is_target_reachable(): 
					distance_reduction += TEST_DISTANCE_INTERVAL
					direction = global_position.direction_to(_body_to_react_to.global_position)
					distance = global_position.distance_to(_body_to_react_to.global_position) - distance_reduction
					navigation_agent.target_position = global_position + direction * distance
					tries += 1
					if tries > MAX_TRIES_FIND_NEW_POSITION:
						break

		entity.direction = global_position.direction_to(navigation_agent.get_next_path_position())
	

func _on_body_entered_vision(body):
	if prioritize == BehaviorType.CHASE:
		# Chase
		if body in chase_specific:
			_behavior = BehaviorType.CHASE
			_body_to_react_to = body
		for group in chase:
			if _body_to_react_to != null:
				if group in _body_to_react_to.get_groups():
					_behavior = BehaviorType.CHASE
			elif group in body.get_groups():
				_behavior = BehaviorType.CHASE
				_body_to_react_to = body
				return
		# Evade
		if body in evade_specific:
			_behavior = BehaviorType.EVADE
			_body_to_react_to = body
		for group in evade:	
			if _body_to_react_to != null:
				if group in _body_to_react_to.get_groups():
					_behavior = BehaviorType.EVADE
			elif group in body.get_groups():
				_behavior = BehaviorType.EVADE
				_body_to_react_to = body
				return
	
	elif prioritize == BehaviorType.EVADE:
		# Evade
		if body in evade_specific:
			_behavior = BehaviorType.EVADE
			_body_to_react_to = body
		for group in evade:
			if _body_to_react_to != null:
				if group in _body_to_react_to.get_groups():
					_behavior = BehaviorType.EVADE
			elif group in body.get_groups():
				_behavior = BehaviorType.EVADE
				_body_to_react_to = body
				return

		# Chase
		if body in chase_specific:
			_behavior = BehaviorType.CHASE
			_body_to_react_to = body
		for group in chase:
			if _body_to_react_to != null:
				if group in _body_to_react_to.get_groups():
					_behavior = BehaviorType.CHASE
			elif group in body.get_groups():
				_behavior = BehaviorType.CHASE
				_body_to_react_to = body
				return

func _on_body_exited_vision(body):
	if body == _body_to_react_to:
		entity.direction = Vector2.ZERO

func get_reactive_body():
	return _body_to_react_to

func enable():
	enabled = true

func disable():
	enabled = false
	entity.direction = Vector2.ZERO
