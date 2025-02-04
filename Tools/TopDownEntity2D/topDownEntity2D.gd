class_name TopDownEntity2D extends Node2D

## Base for entities in a top down 2D environment. Handles movement of the body. Moves towards given direction with given speed.


# region constants
## Ignore impulses with vector length under the floor
const IMPULSE_FLOOR = .1
const VELOCITY_FLOOR = 5
# endregion


# region @export variables
@onready var navigation_agent : NavigationAgent2D = get_navigation_agent_if_availabe()
func get_navigation_agent_if_availabe():
	if not self.get_parent().has_node("NavigationAgent2D"):
		return null
	else:
		return self.get_parent().get_node("NavigationAgent2D")

@onready var body: CharacterBody2D = self.get_parent()

@export var direction: Vector2
@export var speed: float = 50
@export var impulse_size: float = 100
@export var is_static: bool = false
@export var stun_stand_still_time = .5

## Smoothness of velocity change. A higher number means less smoothing.
@export var velocity_lerp_weight: float = 15
## If true will react to impulses through the impulse function.
@export var reacts_to_impulses: bool = true
## If false may react to impulses but won't move towards direction.
@export var reacts_to_direction: bool = true
# endregion


# region public variabes
## Returns true if body has velocity above VELOCITY_FLOOR
var is_moving: bool:
	set(value):
		pass
	get:
		return (body.velocity.length() > VELOCITY_FLOOR)
# endregion


# region private variables
var _impulses: Array[Vector2] = []
# endregion

var _frozen_timer : Timer
	

# region optional built-in virtual _init method
func _ready():
	_frozen_timer = Timer.new()
	_frozen_timer.one_shot = true
	add_child(_frozen_timer)
	# Change motion mode from platformer to top down
	body.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
# endregion


# region remaining built-in virtual methods
func _physics_process(delta_time):
	_apply_new_velocity(delta_time)
	if not is_static:
		body.move_and_slide()
# endregion


# region public methods
## Teleports the body to the target position
func teleport(p_position: Vector2):
	body.global_position = body.p_position


## Adds an impulse to the body
func add_impulse(impulse: Vector2):
	_impulses.append(impulse)


func stun():
	_frozen_timer.start(stun_stand_still_time)


func stop():
	direction = Vector2.ZERO
# endregion


# region private methods
func _apply_new_velocity(delta_time):
	if not is_static:
		var target_velocity
		if _frozen_timer.time_left != 0 or not reacts_to_direction:
			target_velocity = Vector2.ZERO
		else:
			target_velocity = speed * direction.normalized()
		# The lerping needs to be framerate independent https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
		body.velocity = body.velocity.lerp(target_velocity, 1 - exp(delta_time * -velocity_lerp_weight))
		if navigation_agent:
			if navigation_agent.avoidance_enabled:
				navigation_agent.set_velocity(body.velocity)
			else:
				_on_velocity_computed(body.velocity)

		# Add all impulses
		if reacts_to_impulses:
			for impulse in _impulses:
				body.velocity += (impulse * impulse_size)
			_impulses = []
		

func _on_velocity_computed(safe_velocity: Vector2):
	body.velocity = safe_velocity
	
# endregion
